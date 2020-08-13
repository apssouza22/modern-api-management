#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen
PROTO_ROOT="$ROOT/protos/local"
MODULES_FILE=$PROTO_ROOT/modules

rm -rf "$GEN_PATH/java"
mkdir -p "$GEN_PATH/java"

function buildModule() {
  modulePath="$1"
  moduleName="$2"

  JAVA_PATH="$GEN_PATH/java/$moduleName/src/main/java"

  mkdir -p "$JAVA_PATH"

  echo "Building directory \"$PROTO_ROOT/$modulePath\""

  while read proto; do
    generateCode "$PROTO_ROOT/$proto" "$JAVA_PATH"
  done <"$PROTO_ROOT/$modulePath/dependencies"

  generateCode "$PROTO_ROOT/$modulePath/" "$JAVA_PATH"

  sed "s/PACKAGE_NAME/${moduleName}/g" "$ROOT/assets/pom-template.xml" >"$GEN_PATH/java/$moduleName/pom.xml"
}

function generateCode() {
  protos="$1"
  javaOut="$2"

  for proto in $(find "$protos" -name "*.proto"); do
    echo "Generating Java code for $proto"

    protoc \
      -I "$ROOT"/protos/local \
      -I "$ROOT"/protos/thirdparty/grpc-gateway \
      -I "$ROOT"/protos/thirdparty/googleapis \
      --java_out="$javaOut" \
      "$proto"

    protoc \
      -I "$ROOT"/protos/local \
      -I "$ROOT"/protos/thirdparty/grpc-gateway \
      -I "$ROOT"/protos/thirdparty/googleapis \
      --grpc-java_out="$javaOut" \
      --plugin=protoc-gen-grpc-java=/usr/local/bin/protoc-gen-grpc-java \
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
