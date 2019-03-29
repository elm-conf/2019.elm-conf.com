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
    <script src="/index.min.js"></script>
    <script>
      Elm.Main.init();
    </script>
  </body>
</html>
EOF
