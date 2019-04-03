#!/usr/bin/env bash
set -euo pipefail

cat <<EOF
<html lang="en">
  <head>
    <title>elm-conf</title>
    <meta charset="utf-8" />
    <link rel="icon" href="/static/images/favicon.ico" />
    <link href="https://fonts.googleapis.com/css?family=Vollkorn|Work+Sans" rel="stylesheet">
    <style>html, body { margin: 0; width: 100%; height: 100%; } * { box-sizing: border-box; }</style>
  </head>
  <body>
    <script src="/index.min.js"></script>
    <script>
      Elm.Main.init();
    </script>
  </body>
</html>
EOF
