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
      var app = Elm.Main.init({
        flags: {
          graphqlEndpoint: "${GRAPHQL_ENDPOINT:-https://cfp.elm-conf.com/graphql}",
          session: parseToken(localStorage.getItem('token'))
        }
      });
      function parseToken(token) {
        if (token === null) return null
        var userId = JSON.parse(atob(token.split('.')[1])).user_id
        return { userId, token }
      }
      app.ports.setToken.subscribe(function (token) {
        localStorage.setItem('token', token)
        setTimeout(function() { app.ports.tokenChanges.send(parseToken(token)); }, 0);
      })
      window.addEventListener('storage', function (event) {
        if (event.storageArea === localStorage && event.key === 'token') {
          app.ports.tokenChanges.send(parseToken(event.newValue))
        }
      })
    </script>
  </body>
</html>
EOF
