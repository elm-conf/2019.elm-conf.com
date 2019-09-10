#!/usr/bin/env bash
set -euo pipefail

make dist

cd dist
python -m http.server 8001 &
SERVER=$!
cd -

cleanup() {
    kill "$SERVER"
}
trap cleanup EXIT

echo "Opening Cypress"
$(npm bin)/cypress open
