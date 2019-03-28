#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-}"

TITLE="$(grep title: $SRC | sed 's/title: //g')"

cat <<EOF
<html lang="en">
  <head>
    <title>${TITLE}</title>
  </head>
  <body>
    $(cat $SRC)
  </body>
</html>
EOF
