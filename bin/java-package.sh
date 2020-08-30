#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen/java
PROTO_ROOT="$ROOT/protos"
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

    packageModule $moduleName
  done < "$MODULES_FILE"

  echo "*** Package SUCCESS!! ***"
}

packageAll
