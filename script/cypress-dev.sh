#!/usr/bin/env bash
set -euo pipefail

make public

cd public
python -m http.server 8001 &
SERVER=$!
cd -

cleanup() {
    kill "$SERVER"
}
trap cleanup EXIT

echo "Opening Cypress"
$(npm bin)/cypress open
