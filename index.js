const { Elm } = require("./src/Main.elm");
const pagesInit = require("elm-pages");
require("./src/fonts.css");
require("./src/reset.css");

pagesInit({
  mainElmModule: Elm.Main,
  imageAssets: {}
});
