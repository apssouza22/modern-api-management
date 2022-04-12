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

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH=$ROOT/gen
PROTO_ROOT="$ROOT/$srcDir"
MODULES_FILE=$PROTO_ROOT/modules

rm -rf "$GEN_PATH/java"
mkdir -p "$GEN_PATH/java"

function buildModule() {
  modulePath="$1"
  moduleName="$2"

  JAVA_PATH="$GEN_PATH/java/$moduleName/src/main/java"

  mkdir -p "$JAVA_PATH"

  echo "Building directory \"$PROTO_ROOT/$modulePath\""

  generateCode "$PROTO_ROOT/$modulePath/" "$JAVA_PATH"

  sed "s/PACKAGE_NAME/${moduleName}/g" "$ROOT/assets/pom-template.xml" >"$GEN_PATH/java/$moduleName/pom.xml"
  sed -i "s/VERSION/${version}/g" "$GEN_PATH/java/$moduleName/pom.xml"
  generateDependenciesXml "$modulePath" "$moduleName"
}


function generateDependenciesXml(){
  modulePath="$1"
  moduleName="$2"

  echo "Generating dependencies for \"$PROTO_ROOT/$modulePath\""
  DEPENDENCIES="$PROTO_ROOT/$modulePath/dependencies"
  if [ ! -f "$DEPENDENCIES" ]; then
     sed -i "s|DEPENDENCIES| |g" "$GEN_PATH/java/$moduleName/pom.xml"
     return
  fi
  dependencies=''
  while read protoDir; do
    echo "dependencies ${modules[$protoDir]}"
    dependencies="$dependencies<dependency><groupId>com.apssouza.api</groupId><artifactId>${modules[$protoDir]}</artifactId><version>$version</version></dependency>"
  done < "$DEPENDENCIES"

  sed -i "s|<!--DEPENDENCIES-->|${dependencies}|g" "$GEN_PATH/java/$moduleName/pom.xml"

}

function generateCode() {
  protos="$1"
  javaOut="$2"

  for proto in $(find "$protos" -name "*.proto"); do
    echo "Generating Java code for $proto"

    protoc \
      -I "$ROOT"/protos \
      -I "$ROOT" \
      --java_out="$javaOut" \
      "$proto"

    protoc \
      -I "$ROOT"/protos \
      -I "$ROOT" \
      --grpc-java_out="$javaOut" \
      --plugin=protoc-gen-grpc-java=/usr/local/bin/protoc-gen-grpc-java \
      "$proto"
  done
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
  modulesString=""
  while read module; do
    buildPath="$(echo $module | cut -d' ' -f1)"
    moduleName="$(echo $module | cut -d' ' -f2)"

    echo "$buildPath -  $moduleName"
    buildModule $buildPath $moduleName
    modulesString="$modulesString <module>$moduleName</module>"
  done <"$MODULES_FILE"

  sed "s|<!--MODULES-->|${modulesString}|g" "$ROOT/assets/parent-pom-template.xml" > "$GEN_PATH/java/pom.xml"
  sed -i "s/VERSION/${version}/g" "$GEN_PATH/java/pom.xml"
  echo "*** BUILD SUCCESS!! ***"
}

buildAll
