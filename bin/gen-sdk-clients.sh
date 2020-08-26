#!/usr/bin/env bash
set -e

pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

rm -rf "$ROOT/gen/sdk"

for deffile in $(find "$ROOT/docs/swagger/definition/" -name "*.json"); do

  ## Generating Java client
  java -Dfile.encoding=UTF-8 \
    -jar "$ROOT/bin/openapi-generator-cli.jar" \
    generate -g java \
    -i "$deffile" \
    --api-package com.apssouza.bookstore.client.api \
    --model-package com.apssouza.bookstore.client.model \
    --invoker-package com.apssouza.bookstore.client.invoker \
    --group-id com.apssouza.bookstore \
    --artifact-id bookstore-api-client \
    --artifact-version 0.0.1-SNAPSHOT \
    --library resttemplate \
    -o "$ROOT/gen/sdk/java"

  ## Generating Golang client
  java -Dfile.encoding=UTF-8 \
    -jar "$ROOT/bin/openapi-generator-cli.jar" \
    generate -g go \
    -i "$deffile" \
    -o "$ROOT/gen/sdk/go"
done
