#!/usr/bin/env bash
set -euo pipefail

cat <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>elm-conf</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="icon" href="/images/favicon.ico" />
    <link href="https://fonts.googleapis.com/css?family=Vollkorn|Work+Sans" rel="stylesheet">
    <style>html, body { margin: 0; width: 100%; height: 100%; } * { box-sizing: border-box; }</style>

    <!-- bugsnag JS needs to be included in the head, according to their docs -->
    <script src="//d2wy8f7a9ursnm.cloudfront.net/v6/bugsnag.min.js"></script>
    <script>window.bugsnagClient = bugsnag('f0ddc87348e5660ed4d152c9be567cd7')</script>
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
      });
      app.ports.removeToken.subscribe(function () {
        localStorage.removeItem('token');
      });
      window.addEventListener('storage', function (event) {
        if (event.storageArea === localStorage && event.key === 'token') {
          app.ports.tokenChanges.send(event.newValue)
        }
      });
    </script>
  </body>
</html>
EOF
