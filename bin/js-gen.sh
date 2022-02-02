#!/bin/bash
set -e
function usage() {
    echo "Generate Java files into gen/java directory
Usage: $0 apis-dir version

Example: $0 ~/my/path/apis 0.0.12"
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

  JAVA_PATH="$GEN_PATH/js/$moduleName"

  mkdir -p "$JAVA_PATH"

  echo "Generating dependencies for \"$PROTO_ROOT/$modulePath\""
  # first, generate the dependencies
  while read proto; do
    generateCode "$PROTO_ROOT/$proto" "$JAVA_PATH"
  done <"$PROTO_ROOT/$modulePath/dependencies"

  # then, generate the module code itself
  generateCode "$PROTO_ROOT/$modulePath/protos/*.proto" "$JAVA_PATH"

  cat >$JAVA_PATH/package.json <<EOF
  {
    "name": "@deem/${moduleName#v}",
    "version": "${version#v}",
    "description": "Generated protobuf types for phoenix microservices"
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

function buildAll() {
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
