#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen/java
PROTO_ROOT="$ROOT/protos/local"
MODULES_FILE=$PROTO_ROOT/modules

function installModule() {
  moduleName="$1"

  echo "Packaging module $moduleName"
  mvn clean install -f "$GEN_PATH/$moduleName/pom.xml"

  #  mvn install:install-file \
  #    -Dfile="$GEN_PATH/$moduleName/target/$moduleName-1.0.0.jar" \
  #    -DgroupId=com.apssouza.api.bookstore \
  #    -DartifactId="$moduleName" \
  #    -Dversion=1.0-SNAPSHOT \
  #    -Dpackaging=jar \
  #    -DpomFile="$GEN_PATH/$moduleName/pom.xml"
}

function installAll() {
  echo "Install modules"

  while read module; do
    moduleName="$(echo $module | cut -d' ' -f2)"

    installModule $moduleName
  done <"$MODULES_FILE"

  echo "*** Install SUCCESS!! ***"
}

installAll
