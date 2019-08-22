port module PagesNew exposing (application, PageRoute, all, pages, routeToString, Image, imageUrl, images, allImages)

import Dict exposing (Dict)
import Color exposing (Color)
import Head
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Mark
import Pages
import Pages.ContentCache exposing (Page)
import Pages.Manifest exposing (DisplayMode, Orientation)
import Pages.Manifest.Category as Category exposing (Category)
import RawContent
import Url.Parser as Url exposing ((</>), s)
import Pages.Document


port toJsPort : Json.Encode.Value -> Cmd msg


application :
    { init : ( userModel, Cmd userMsg )
    , update : userMsg -> userModel -> ( userModel, Cmd userMsg )
    , subscriptions : userModel -> Sub userMsg
    , view : userModel -> List ( List String, metadata ) -> Page metadata view -> { title : String, body : Html userMsg }
    , head : metadata -> List Head.Tag
    , documents : List (Pages.Document.DocumentParser metadata view)
    , manifest :
        { backgroundColor : Maybe Color
        , categories : List Category
        , displayMode : DisplayMode
        , orientation : Orientation
        , description : String
        , iarcRatingId : Maybe String
        , name : String
        , themeColor : Maybe Color
        , startUrl : PageRoute
        , shortName : Maybe String
        , sourceIcon : Image
        }
    }
    -> Pages.Program userModel userMsg metadata view
application config =
    Pages.application
        { init = config.init
        , view = config.view
        , update = config.update
        , subscriptions = config.subscriptions
        , document = Dict.fromList config.documents
        , content = RawContent.content
        , toJsPort = toJsPort
        , head = config.head
        , manifest =
            { backgroundColor = config.manifest.backgroundColor
            , categories = config.manifest.categories
            , displayMode = config.manifest.displayMode
            , orientation = config.manifest.orientation
            , description = config.manifest.description
            , iarcRatingId = config.manifest.iarcRatingId
            , name = config.manifest.name
            , themeColor = config.manifest.themeColor
            , startUrl = Just (routeToString config.manifest.startUrl)
            , shortName = config.manifest.shortName
            , sourceIcon = "./" ++ imageUrl config.manifest.sourceIcon
            }
        }


type PageRoute = PageRoute (List String)

type Image = Image (List String)

imageUrl : Image -> String
imageUrl (Image path) =
    "/"
        ++ String.join "/" ("images" :: path)

all : List PageRoute
all =
    [ (PageRoute [ "about" ])
    , (PageRoute [ "cfp" ])
    , (PageRoute [ "cfp", "proposals" ])
    , (PageRoute [ "frequently-asked-questions" ])
    , (PageRoute [  ])
    , (PageRoute [ "register" ])
    , (PageRoute [ "schedule" ])
    , (PageRoute [ "speak-at-elm-conf" ])
    , (PageRoute [ "speakers", "abadi-kurniawan" ])
    , (PageRoute [ "speakers", "brooke-angel" ])
    , (PageRoute [ "speakers", "ian-mackenzie" ])
    , (PageRoute [ "speakers", "james-carlson" ])
    , (PageRoute [ "speakers", "james-gary" ])
    , (PageRoute [ "speakers", "katie-hughes" ])
    , (PageRoute [ "speakers", "katja-mordaunt" ])
    , (PageRoute [ "speakers", "liz-krane" ])
    , (PageRoute [ "speakers", "ryan-frazier" ])
    , (PageRoute [ "speakers", "tessa-kelly" ])
    , (PageRoute [ "sponsors" ])
    , (PageRoute [ "sponsorship" ])
    ]

pages =
    { about = (PageRoute [ "about" ])
    , cfp = (PageRoute [ "cfp" ])
    , frequentlyAskedQuestions = (PageRoute [ "frequently-asked-questions" ])
    , index = (PageRoute [  ])
    , register = (PageRoute [ "register" ])
    , schedule = (PageRoute [ "schedule" ])
    , speakAtElmConf = (PageRoute [ "speak-at-elm-conf" ])
    , speakers =
        { abadiKurniawan = (PageRoute [ "speakers", "abadi-kurniawan" ])
        , brookeAngel = (PageRoute [ "speakers", "brooke-angel" ])
        , ianMackenzie = (PageRoute [ "speakers", "ian-mackenzie" ])
        , jamesCarlson = (PageRoute [ "speakers", "james-carlson" ])
        , jamesGary = (PageRoute [ "speakers", "james-gary" ])
        , katieHughes = (PageRoute [ "speakers", "katie-hughes" ])
        , katjaMordaunt = (PageRoute [ "speakers", "katja-mordaunt" ])
        , lizKrane = (PageRoute [ "speakers", "liz-krane" ])
        , ryanFrazier = (PageRoute [ "speakers", "ryan-frazier" ])
        , tessaKelly = (PageRoute [ "speakers", "tessa-kelly" ])
        , all = [ (PageRoute [ "speakers", "abadi-kurniawan" ]), (PageRoute [ "speakers", "brooke-angel" ]), (PageRoute [ "speakers", "ian-mackenzie" ]), (PageRoute [ "speakers", "james-carlson" ]), (PageRoute [ "speakers", "james-gary" ]), (PageRoute [ "speakers", "katie-hughes" ]), (PageRoute [ "speakers", "katja-mordaunt" ]), (PageRoute [ "speakers", "liz-krane" ]), (PageRoute [ "speakers", "ryan-frazier" ]), (PageRoute [ "speakers", "tessa-kelly" ]) ]
        }
    , sponsors = (PageRoute [ "sponsors" ])
    , sponsorship = (PageRoute [ "sponsorship" ])
    , all = [ (PageRoute [ "about" ]), (PageRoute [ "cfp" ]), (PageRoute [ "frequently-asked-questions" ]), (PageRoute [  ]), (PageRoute [ "register" ]), (PageRoute [ "schedule" ]), (PageRoute [ "speak-at-elm-conf" ]), (PageRoute [ "sponsors" ]), (PageRoute [ "sponsorship" ]) ]
    }

urlParser : Url.Parser (PageRoute -> a) a
urlParser =
    Url.oneOf
        [ Url.map (PageRoute [ "about" ]) (s "about")
        , Url.map (PageRoute [ "cfp" ]) (s "cfp")
        , Url.map (PageRoute [ "cfp", "proposals" ]) (s "cfp" </> s "proposals")
        , Url.map (PageRoute [ "frequently-asked-questions" ]) (s "frequently-asked-questions")
        , Url.map (PageRoute [  ]) (s "index")
        , Url.map (PageRoute [ "register" ]) (s "register")
        , Url.map (PageRoute [ "schedule" ]) (s "schedule")
        , Url.map (PageRoute [ "speak-at-elm-conf" ]) (s "speak-at-elm-conf")
        , Url.map (PageRoute [ "speakers", "abadi-kurniawan" ]) (s "speakers" </> s "abadi-kurniawan")
        , Url.map (PageRoute [ "speakers", "brooke-angel" ]) (s "speakers" </> s "brooke-angel")
        , Url.map (PageRoute [ "speakers", "ian-mackenzie" ]) (s "speakers" </> s "ian-mackenzie")
        , Url.map (PageRoute [ "speakers", "james-carlson" ]) (s "speakers" </> s "james-carlson")
        , Url.map (PageRoute [ "speakers", "james-gary" ]) (s "speakers" </> s "james-gary")
        , Url.map (PageRoute [ "speakers", "katie-hughes" ]) (s "speakers" </> s "katie-hughes")
        , Url.map (PageRoute [ "speakers", "katja-mordaunt" ]) (s "speakers" </> s "katja-mordaunt")
        , Url.map (PageRoute [ "speakers", "liz-krane" ]) (s "speakers" </> s "liz-krane")
        , Url.map (PageRoute [ "speakers", "ryan-frazier" ]) (s "speakers" </> s "ryan-frazier")
        , Url.map (PageRoute [ "speakers", "tessa-kelly" ]) (s "speakers" </> s "tessa-kelly")
        , Url.map (PageRoute [ "sponsors" ]) (s "sponsors")
        , Url.map (PageRoute [ "sponsorship" ]) (s "sponsorship")
        ] 

images =
    { elmLogo = (Image [ "elm-logo.svg" ])
    , speakers =
        { abadiKurniawan = (Image [ "speakers", "abadi-kurniawan.jpg" ])
        , brookeAngel = (Image [ "speakers", "brooke-angel.jpg" ])
        , ianMackenzie = (Image [ "speakers", "ian-mackenzie.jpeg" ])
        , jamesCarlson = (Image [ "speakers", "james-carlson.jpg" ])
        , jamesGary = (Image [ "speakers", "james-gary.jpg" ])
        , katieHughes = (Image [ "speakers", "katie-hughes.jpeg" ])
        , katjaMordaunt = (Image [ "speakers", "katja-mordaunt.jpg" ])
        , lizKrane = (Image [ "speakers", "liz-krane.jpg" ])
        , ryanFrazier = (Image [ "speakers", "ryan-frazier.jpg" ])
        , tessaKelly = (Image [ "speakers", "tessa-kelly.png" ])
        , all = [ (Image [ "speakers", "abadi-kurniawan.jpg" ]), (Image [ "speakers", "brooke-angel.jpg" ]), (Image [ "speakers", "ian-mackenzie.jpeg" ]), (Image [ "speakers", "james-carlson.jpg" ]), (Image [ "speakers", "james-gary.jpg" ]), (Image [ "speakers", "katie-hughes.jpeg" ]), (Image [ "speakers", "katja-mordaunt.jpg" ]), (Image [ "speakers", "liz-krane.jpg" ]), (Image [ "speakers", "ryan-frazier.jpg" ]), (Image [ "speakers", "tessa-kelly.png" ]) ]
        }
    , waves = (Image [ "waves.svg" ])
    , all = [ (Image [ "elm-logo.svg" ]), (Image [ "waves.svg" ]) ]
    }

allImages : List Image
allImages =
    [(Image [ "elm-logo.svg" ])
    , (Image [ "speakers", "abadi-kurniawan.jpg" ])
    , (Image [ "speakers", "brooke-angel.jpg" ])
    , (Image [ "speakers", "ian-mackenzie.jpeg" ])
    , (Image [ "speakers", "james-carlson.jpg" ])
    , (Image [ "speakers", "james-gary.jpg" ])
    , (Image [ "speakers", "katie-hughes.jpeg" ])
    , (Image [ "speakers", "katja-mordaunt.jpg" ])
    , (Image [ "speakers", "liz-krane.jpg" ])
    , (Image [ "speakers", "ryan-frazier.jpg" ])
    , (Image [ "speakers", "tessa-kelly.png" ])
    , (Image [ "waves.svg" ])
    ]

routeToString : PageRoute -> String
routeToString (PageRoute route) =
    "/"
      ++ (route |> String.join "/")

