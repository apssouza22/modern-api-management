#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen
JAVA_PATH=$GEN_PATH/java/src/main/java

function installModule() {
  moduleName="$1"

  echo "Installing module $moduleName"
  mvn install:install-file \
    -Dfile="$GEN_PATH/java/$moduleName/target/$moduleName-1.0.0.jar" \
    -DgroupId=com.apssouza.api \
    -DartifactId="$moduleName" \
    -Dversion=1.0-SNAPSHOT \
    -Dpackaging=jar \
    -DpomFile="$GEN_PATH/java/$moduleName/pom.xml"
}

function installAll() {
  echo "Installing modules"

  while read module; do
    moduleName="$(echo $module | cut -d' ' -f2)"

    echo "$buildPath -  $moduleName"
    installModule $moduleName
  done <modules

  echo "*** Install SUCCESS!! ***"
}

installAll
