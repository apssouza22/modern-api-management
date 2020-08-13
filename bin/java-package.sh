#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen/java
PROTO_ROOT="$ROOT/protos/local"
MODULES_FILE=$PROTO_ROOT/modules

function packageModule() {
  moduleName="$1"

  echo "Packaging module $moduleName"
  mvn package -f "$GEN_PATH/$moduleName/pom.xml"
}

function packageAll() {
  echo "Packaging modules"

  while read module; do
    moduleName="$(echo $module | cut -d' ' -f2)"

    echo "$buildPath -  $moduleName"
    packageModule $moduleName
  done < $MODULES_FILE

  echo "*** Package SUCCESS!! ***"
}

packageAll


protoc \
      -I /workspace/bin/../protos/local \
      -I /workspace/bin/../protos/thirdparty/grpc-gateway \
      -I /workspace/bin/../protos/thirdparty/googleapis \
      --grpc-java_out="$javaOut" \
      --plugin=protoc-gen-grpc-java=protoc-gen-grpc-java \
      /workspace/bin/../protos/local/book/v1/books.proto