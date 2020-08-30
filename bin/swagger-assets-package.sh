#!/bin/bash
set -e

######## Package the required Swagger assets to easily distribute to different languages ######

# Getting the script location path
pwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$pwd/.."

rm -rf "$ROOT/docs/swagger/definition"
cp -r "$ROOT/gen/swagger/apssouza" "$ROOT/docs/swagger/definition"

# Packaging the Swagger assets for Golang
statik -m -f -src "$ROOT/docs/swagger/"
rm -rf "$ROOT/gen/go/statik"
mv "$ROOT/statik" "$ROOT/gen/go/statik"

# Packaging the Swagger assets for Java
JAVA_ASSETS="$ROOT/gen/java-assets"
rm -rf "$JAVA_ASSETS"
mkdir -p "$JAVA_ASSETS/src/main/resources"
cp -r  "$ROOT/docs/swagger/" "$JAVA_ASSETS/src/main/resources/public"
cp "$ROOT/assets/assets-pom.xml" "$JAVA_ASSETS/pom.xml"
mvn clean install -f "$JAVA_ASSETS/pom.xml"
