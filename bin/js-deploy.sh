#!/bin/bash
set -e

function usage() {
    echo "Deploy JS artefacts.
    Usage: $0 phoenix-apis-dir
    Example: $0 ./protos"
}

if [ "$#" -ge 1 ]; then
    srcDir="$1"
else
    usage
    exit
fi

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen/js
PROTO_ROOT="$ROOT/$srcDir"
MODULES_FILE=$PROTO_ROOT/modules

function deployModule() {
  moduleName="$1"

  echo "Deploying module $moduleName"
  npm publish --registry https://artifactory.COMPANY.com/artifactory/api/npm/npm-local/ "$GEN_PATH/$moduleName"
}

function deployAll() {
  echo "Deploying modules"

  while read module; do
    moduleName="$(echo $module | cut -d' ' -f2)"

    deployModule $moduleName
  done < "$MODULES_FILE"

  echo "*** Deploy SUCCESS!! ***"
}

deployAll
