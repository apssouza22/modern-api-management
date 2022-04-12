#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen/java

function installAll() {
  echo "Install modules"
  mvn clean install -f "$GEN_PATH/pom.xml"
  echo "*** Install SUCCESS!! ***"
}

installAll
