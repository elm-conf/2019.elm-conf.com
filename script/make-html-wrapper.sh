#!/usr/bin/env bash
set -euo pipefail

cat <<EOF
<html lang="en">
  <head>
    <title>elm-conf</title>
    <meta charset="utf-8" />
    <link rel="icon" href="/images/favicon.ico" />
    <link href="https://fonts.googleapis.com/css?family=Vollkorn|Work+Sans" rel="stylesheet">
    <style>html, body { margin: 0; width: 100%; height: 100%; } * { box-sizing: border-box; }</style>
  </head>
  <body>
    <script src="/index.min.js"></script>
    <script>
      var app = Elm.Main.init({
        flags: {
          graphqlEndpoint: "${GRAPHQL_ENDPOINT:-/graphql}",
          token: localStorage.getItem('token')
        }
      });
      app.ports.setToken.subscribe(function (token) {
        localStorage.setItem('token', token)
        setTimeout(function() { app.ports.tokenChanges.send(token); }, 0);
      })
      window.addEventListener('storage', function (event) {
        if (event.storageArea === localStorage && event.key === 'token') {
          app.ports.tokenChanges.send(event.newValue)
        }
      })
    </script>
  </body>
</html>
EOF
