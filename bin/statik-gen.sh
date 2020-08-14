#!/bin/bash
set -e

# Getting the script location path
pwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$pwd/.."

rm -rf "$ROOT/docs/swagger/definition"
cp -r "$ROOT/gen/swagger/" "$ROOT/docs/swagger/definition"

statik -m -f -src "$ROOT/docs/swagger/"
mv "$ROOT/statik" "$ROOT/gen/go/statik"
