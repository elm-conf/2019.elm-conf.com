#!/usr/bin/env bash
set -euo pipefail

make public

cd public
python -m http.server 8001 > /dev/null 2>&1 &
SERVER=$!
cd -

echo "serving /public on PID $SERVER"

cleanup() {
    kill "$SERVER"
}
trap cleanup EXIT

echo "Running Cypress"
$(npm bin)/cypress run
