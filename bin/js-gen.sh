#!/bin/bash
set -e
function usage() {
    echo "Generate Java files into gen/java directory
Usage: $0 apis-dir version

Example: $0 ./protos 0.0.12"
}

if [ "$#" -ge 2 ]; then
    srcDir="$1"
    version="$2"
else
    usage
    exit
fi

PROTOC_GEN_GRPC_PATH="$(npm prefix -g)/bin/grpc_tools_node_protoc_plugin"
PROTOC_GEN_TS_PATH="$(npm prefix -g)/bin/protoc-gen-ts"

if [[ ! -r $PROTOC_GEN_TS_PATH || ! -r $PROTOC_GEN_GRPC_PATH ]]; then
  echo "Expected $PROTOC_GEN_TS_PATH and $PROTOC_GEN_GRPC_PATH to exist"
  exit 1
fi

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen
PROTO_ROOT="$ROOT/$srcDir"
MODULES_FILE=$PROTO_ROOT/modules

rm -rf "$GEN_PATH/js"
mkdir -p "$GEN_PATH/js"

function buildModule() {
  modulePath="$1"
  moduleName="$2"

  JS_PATH="$GEN_PATH/js/$moduleName"

  mkdir -p "$JS_PATH"

  generatePackageJson $modulePath $moduleName
  generateCode "$PROTO_ROOT/$modulePath/*.proto" "$JS_PATH"
  replaceRelativeImports$modulePath $moduleName
}


function generatePackageJson(){
  modulePath="$1"
  moduleName="$2"

  echo "Generating dependencies for \"$PROTO_ROOT/$modulePath\""

  dependencies=''
  while read protoDir; do
    echo "dependencies ${modules[$protoDir]}"
    # Avoiding duplicated dependencies
    if [[ "$dependencies" != *"${modules[$protoDir]}"* ]]; then
      dependencies="$dependencies,
      \"@deem/${modules[$protoDir]}\": \"^$version\""
    fi
  done <"$PROTO_ROOT/$modulePath/dependencies"

  dependencies=${dependencies:1} # remove , from the beginning of string

  cat >$JS_PATH/package.json <<EOF
  {
    "name": "@deem/${moduleName#v}",
    "version": "${version#v}",
    "description": "Generated protobuf types for phoenix microservices",
    "dependencies": {
      ${dependencies#v}
    }
  }
EOF

}

function generateCode() {
  protos="$1"
  javaOut="$2"
  directory=$(dirname "$protos")
  name=$(basename "$protos")
  for proto in $(find "$directory" -name "$name"  -and -name "*.proto"); do
    echo "Generating code for $proto"

    protoc \
      -I "$PROTO_ROOT" \
      -I "$ROOT" \
      --plugin="protoc-gen-grpc=/usr/lib/node_modules/protoc-gen-grpc/bin/grpc_node_plugin" \
      --plugin="protoc-gen-ts=${PROTOC_GEN_TS_PATH}" \
      --js_out="import_style=commonjs,binary:${javaOut}" \
      --ts_out="service=grpc-node:${javaOut}" \
      --grpc_out="${javaOut}" \
      "$proto"

  done
}


# Replacing relative dependencies import by module names. Ex ../common/v1 -> @common-v1
function replaceRelativeImports(){
  modulePath="$1"
  moduleName="$2"

  DEPENDENCIES="$PROTO_ROOT/$modulePath/dependencies"
  if [ ! -f "$DEPENDENCIES" ]; then
     return
  fi
  echo "Replacing relative imports for \"$PROTO_ROOT/$modulePath\" files"
  while read proto; do
    directory=$(dirname "$proto")
    moduleDepName="${modules[$directory]}"
    echo "Replacing relative imports for ./$directory  by  @$moduleDepName"
    FILES="$JS_PATH/$modulePath/*"
    for FILE in $FILES; do
      if [ -f "$FILE" ]; then
        sed -i "s|\.\/${directory}|@${moduleDepName}/${directory}|g" "${FILE}"
        sed -i "s|\"\..*@|\"@|g" "${FILE}" # removing "../../ until find @
        sed -i "s|'\..*@|'@|g" "${FILE}" # removing '../../ until find @
      fi
    done
  done < "$DEPENDENCIES"

}

declare -A modules=()

# This is only for back compatibility.
# Today dependencies files contains proto names instead of modules name
# Mapping protos directory to module names
function mapModules(){
  while read module; do
      buildPath="$(echo $module | cut -d' ' -f1)"
      moduleName="$(echo $module | cut -d' ' -f2)"
      modules["$buildPath"]="$moduleName"
      echo $buildPath
    done <"$MODULES_FILE"
}


function buildAll() {
  mapModules

  echo "Buidling service's protocol buffers"

  while read module; do
    buildPath="$(echo $module | cut -d' ' -f1)"
    moduleName="$(echo $module | cut -d' ' -f2)"

    echo "$buildPath -  $moduleName"
    buildModule $buildPath $moduleName
  done <"$MODULES_FILE"

  echo "*** BUILD SUCCESS!! ***"
}

buildAll
