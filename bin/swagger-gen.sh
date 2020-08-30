#!/bin/bash
set -e

# Getting the script location path
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT="$pwd/.."
PROTO_ROOT="$ROOT/protos/local"
GEN_PATH="$ROOT/gen/swagger"

rm -rf "$GEN_PATH"
mkdir -p "$GEN_PATH"

for proto in $(find "$PROTO_ROOT" -name "*.proto"); do

  protoc \
    -I "$PROTO_ROOT" \
    --openapiv2_out=grpc_api_configuration="$ROOT/docs/config/services.yml":"$ROOT/gen/swagger" \
    "$proto"
done
