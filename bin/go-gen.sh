#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."

GEN_PATH="$ROOT/gen/go"
PROTO_ROOT="$ROOT/protos"

rm -rf "$GEN_PATH"
mkdir -p "$GEN_PATH"

cp "$ROOT/assets/go.mod" "$GEN_PATH"

for proto in $(find "$PROTO_ROOT" -name "*.proto"); do
  echo "Generating Go code for $proto"
  protoc \
    -I "$PROTO_ROOT" \
    --go_out=plugins=grpc:"$GEN_PATH" \
    "$proto"
done
