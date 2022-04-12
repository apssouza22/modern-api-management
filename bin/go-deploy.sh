#!/usr/bin/env bash
set -e

pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen
GO_GEN_PATH=$GEN_PATH/go
GO_REPO_NAME=protobuf-gen-code
GO_REPO_URL="git@github.com:apssouza22/$GO_REPO_NAME"
CURRENT_BRANCH=${GO_REPO_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}
GO_PKG=gitlab.COMPANY.com/apis-go

# Flags
PUBLISH=0
RELEASE_PATCH=0

SEMVER_LIB=$ROOT/assets/semver
# Check if the semver tool is available. It is part of the repo and no explicit download is required
if [ ! -f $SEMVER_LIB ]; then
  echo "Missing semver lib. It should be available in the repo
If you have accidentally deleted it please checkout from master -- git checkout semver"
  exit 1
fi


# updateGoRepository is responsible for cloning the go repository (GO_REPO_NAME:- apis-go), creating a new branch and pushing
# the changes to the repository
function updateGoRepository() {
  echo "Cloning repo: $GO_REPO_URL"

  if [ "$CURRENT_BRANCH" == "HEAD" ]; then
    echo "Not possible to identify current git branch (detached head)"
    exit 1
  fi

  cd $GEN_PATH
  rm -rf $GEN_PATH/$GO_REPO_NAME

  git clone --depth 1 "$GO_REPO_URL.git" --branch master --single-branch "$GEN_PATH/$GO_REPO_NAME"

  setupBranch $GEN_PATH/$GO_REPO_NAME

  # Copy the generated files out of the pb-* path into the repository
  cp -R $GO_GEN_PATH/* $GEN_PATH/$GO_REPO_NAME

  commitAndPush $GEN_PATH/$GO_REPO_NAME

}

# createPatchRelease fetches the latest tag and increments the patch version
# and tags it with the incremented version
# Input:
#   reponame:    The name of the repository from which the tag should be fetched
function createPatchRelease() {
  cd $ROOT
  local reponame="$1"
  local latestTag=$(getLatestTag $reponame)
  local incrementedTag=$(incrementPatchVersion $latestTag)
  tagAndPush "$reponame" "$incrementedTag"
  printf "\n\n New version tag $incrementedTag created in both fiji-apis and $GO_REPO_NAME"
}

# getLatestTag gets the latest tag in the given repository.
# The prerequisite is that the repository should be cloned and available in $GEN_PATH/$reponame
# Input:
#   reponame:    The name of the repository from which the tag should be fetched
function getLatestTag() {
  local reponame="$1"
  local latestTag=$(git ls-remote --tags --sort="v:refname" "$GO_REPO_URL.git" | tail -n1 | sed 's/.*\///; s/\^{}//')
  echo $latestTag
}

# incrementPatchVersion method is used to increment the patch version of the given semver
# Input:
#   semver:    The current semver that needs a patch increment
function incrementPatchVersion() {
  local currentVersion="$1"
  local incrementedVersion=$($SEMVER_LIB bump patch $currentVersion)
  echo "v$incrementedVersion"
}

# tagAndPush method is used to tag the repo with the given version and push it to origin (remote)
# Input:
#   reponame:    The name of the repository from which the tag should be fetched
#   tagVersion:    The version with which the repo should be tagged (Format: vX.Y.Z example v0.0.1)
function tagAndPush() {
  local reponame="$1"
  local tagVersion="$2"
  cd $GEN_PATH/$reponame
  git tag "$tagVersion"
  git push origin "$tagVersion"
  cd $ROOT
  git tag "$tagVersion"
  git push origin "$tagVersion"
}

# setupBranch is responsible for validating the current branch and pulling the latest changes from origin
# The current branch will be master in the case of Publish builds
# Input:
#   repopath:    The path of the repository in which the branch should be setup
function setupBranch() {
  local repopath="$1"
  cd $repopath

  echo "Using branch $CURRENT_BRANCH"

  if ! git show-branch $CURRENT_BRANCH; then
    git branch $CURRENT_BRANCH
  fi

  git checkout $CURRENT_BRANCH

  if git ls-remote --heads --exit-code origin $CURRENT_BRANCH; then
    echo "Branch exists on remote, pulling latest changes"
    git pull origin $CURRENT_BRANCH
  fi
}

# commitAndPush adds all the local changes and checks for new changes.
# If there are changes, it commits and pushes the changes to the origin
# Input:
#   repopath:    The path of the repository in which the branch should be setup
function commitAndPush() {
  local repopath="$1"
  cd $repopath

  git add -N .

  if ! git diff --exit-code >/dev/null; then
    git add .
    git commit -m "Auto Creation of Proto"
    git push origin HEAD
  else
    echo "No changes detected for $1"
    RELEASE_PATCH=0
  fi

}

# printDate method prints the current date in the format dd/mm/yyyy hh:mm:ss
function printDate() {
  local dt=$(date -u '+%Y-%m-%d %H:%M:%S %Z')
  echo $dt
}

# showHelp method prints the usage of the command.
function showHelp() {
  echo "Usage:"
  echo "$0 [--publish [--releasePatch] | --latest | --help]"
  echo "  -p | --publish : Enable PUBLISH mode. Changes will be pushed to $GO_REPO_URL"
  echo "  -rp | --releasePatch : Release a patch version. A new tag with be created in $GO_REPO_URL by incrementing patch of the the latest tag"
  echo "  -l | --latest : Shows the latest tag of $GO_REPO_URL"
  echo "  -h | --help : Print help text"
}

# parseArguments method is responsible for parsing the command line arguments
function parseArguments() {
  POSITIONAL=()
  while [[ $# -gt 0 ]]; do
    local key="$1"

    case $key in
    -h | --help)
      showHelp
      shift
      exit 0
      ;;
    -p | --publish)
      PUBLISH=1
      shift
      ;;
    -rp | --releasePatch)
      RELEASE_PATCH=1
      shift
      ;;
    -l | --latest)
      getLatestTag $GO_REPO_NAME
      exit 0
      shift
      ;;
    *)
      echo "Invalid Argument"
      showHelp
      POSITIONAL+=("$1") # save it in an array for later
      shift              # past argument
      ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters
}

# buildAll is the main method responsible for orchestrating the operations
# the input is drawn from the `modules file` which contains space separated key value pair of
# the path to the module and the name of the module
# Eg. air/common/v1 air-common-v1
function buildAll() {
  parseArguments $*

  printf "\n$(printDate) *** Running in PUBLISH Mode ***"
  printf "\nChanges will be pushed to $GO_REPO_URL\n"

  updateGoRepository

  if [ "$RELEASE_PATCH" -eq "1" ]; then
    if [ "$CURRENT_BRANCH" != "master" ]; then
      echo "Only Dry run is supported from Dev Branches. Release should be executed from the master branch of fiji-apis"
      exit 1
    fi
    printf "\n$(printDate) *** Creating a patch release ***\n"
    createPatchRelease "$GO_REPO_NAME"
  fi

  echo "*** $(printDate) BUILD SUCCESS!! ***"
}

# __main__
buildAll $*
