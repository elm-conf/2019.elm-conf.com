port module PagesNew exposing (PathKey, all, allImages, application, buildPage, images, isValidRoute, pages)

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
import Url.Parser as Url exposing ((</>), s)
import Pages.Document
import Pages.Path as Path exposing (Path)


type PathKey
    = PathKey


buildImage : List String -> Path PathKey Path.ToImage
buildImage path =
    Path.buildImage PathKey ("images" :: path)



buildPage : List String -> Path PathKey Path.ToPage
buildPage path =
    Path.buildPage PathKey path
port toJsPort : Json.Encode.Value -> Cmd msg


application :
    { init : ( userModel, Cmd userMsg )
    , update : userMsg -> userModel -> ( userModel, Cmd userMsg )
    , subscriptions : userModel -> Sub userMsg
    , view : userModel -> List ( List String, metadata ) -> Page metadata view -> { title : String, body : Html userMsg }
    , head : metadata -> List Head.Tag
    , documents : List (Pages.Document.DocumentParser metadata view)
    , manifest : Pages.Manifest.Config PathKey
    }
    -> Pages.Program userModel userMsg metadata view
application config =
    Pages.application
        { init = config.init
        , view = config.view
        , update = config.update
        , subscriptions = config.subscriptions
        , document = Dict.fromList config.documents
        , content = content
        , toJsPort = toJsPort
        , head = config.head
        , manifest = config.manifest
        }



all : List (Path PathKey Path.ToPage)
all =
    [ (buildPage [ "about" ])
    , (buildPage [ "cfp" ])
    , (buildPage [ "cfp", "proposals" ])
    , (buildPage [ "frequently-asked-questions" ])
    , (buildPage [  ])
    , (buildPage [ "register" ])
    , (buildPage [ "schedule" ])
    , (buildPage [ "speak-at-elm-conf" ])
    , (buildPage [ "speakers", "abadi-kurniawan" ])
    , (buildPage [ "speakers", "brooke-angel" ])
    , (buildPage [ "speakers", "ian-mackenzie" ])
    , (buildPage [ "speakers", "james-carlson" ])
    , (buildPage [ "speakers", "james-gary" ])
    , (buildPage [ "speakers", "katie-hughes" ])
    , (buildPage [ "speakers", "katja-mordaunt" ])
    , (buildPage [ "speakers", "liz-krane" ])
    , (buildPage [ "speakers", "ryan-frazier" ])
    , (buildPage [ "speakers", "tessa-kelly" ])
    , (buildPage [ "sponsors" ])
    , (buildPage [ "sponsorship" ])
    ]

pages =
    { about = (buildPage [ "about" ])
    , cfp = (buildPage [ "cfp" ])
    , frequentlyAskedQuestions = (buildPage [ "frequently-asked-questions" ])
    , index = (buildPage [  ])
    , register = (buildPage [ "register" ])
    , schedule = (buildPage [ "schedule" ])
    , speakAtElmConf = (buildPage [ "speak-at-elm-conf" ])
    , speakers =
        { abadiKurniawan = (buildPage [ "speakers", "abadi-kurniawan" ])
        , brookeAngel = (buildPage [ "speakers", "brooke-angel" ])
        , ianMackenzie = (buildPage [ "speakers", "ian-mackenzie" ])
        , jamesCarlson = (buildPage [ "speakers", "james-carlson" ])
        , jamesGary = (buildPage [ "speakers", "james-gary" ])
        , katieHughes = (buildPage [ "speakers", "katie-hughes" ])
        , katjaMordaunt = (buildPage [ "speakers", "katja-mordaunt" ])
        , lizKrane = (buildPage [ "speakers", "liz-krane" ])
        , ryanFrazier = (buildPage [ "speakers", "ryan-frazier" ])
        , tessaKelly = (buildPage [ "speakers", "tessa-kelly" ])
        , all = [ (buildPage [ "speakers", "abadi-kurniawan" ]), (buildPage [ "speakers", "brooke-angel" ]), (buildPage [ "speakers", "ian-mackenzie" ]), (buildPage [ "speakers", "james-carlson" ]), (buildPage [ "speakers", "james-gary" ]), (buildPage [ "speakers", "katie-hughes" ]), (buildPage [ "speakers", "katja-mordaunt" ]), (buildPage [ "speakers", "liz-krane" ]), (buildPage [ "speakers", "ryan-frazier" ]), (buildPage [ "speakers", "tessa-kelly" ]) ]
        }
    , sponsors = (buildPage [ "sponsors" ])
    , sponsorship = (buildPage [ "sponsorship" ])
    , all = [ (buildPage [ "about" ]), (buildPage [ "cfp" ]), (buildPage [ "frequently-asked-questions" ]), (buildPage [  ]), (buildPage [ "register" ]), (buildPage [ "schedule" ]), (buildPage [ "speak-at-elm-conf" ]), (buildPage [ "sponsors" ]), (buildPage [ "sponsorship" ]) ]
    }

urlParser : Url.Parser (Path PathKey Path.ToPage -> a) a
urlParser =
    Url.oneOf
        [ Url.map (buildPage [ "about" ]) (s "about")
        , Url.map (buildPage [ "cfp" ]) (s "cfp")
        , Url.map (buildPage [ "cfp", "proposals" ]) (s "cfp" </> s "proposals")
        , Url.map (buildPage [ "frequently-asked-questions" ]) (s "frequently-asked-questions")
        , Url.map (buildPage [  ]) (s "index")
        , Url.map (buildPage [ "register" ]) (s "register")
        , Url.map (buildPage [ "schedule" ]) (s "schedule")
        , Url.map (buildPage [ "speak-at-elm-conf" ]) (s "speak-at-elm-conf")
        , Url.map (buildPage [ "speakers", "abadi-kurniawan" ]) (s "speakers" </> s "abadi-kurniawan")
        , Url.map (buildPage [ "speakers", "brooke-angel" ]) (s "speakers" </> s "brooke-angel")
        , Url.map (buildPage [ "speakers", "ian-mackenzie" ]) (s "speakers" </> s "ian-mackenzie")
        , Url.map (buildPage [ "speakers", "james-carlson" ]) (s "speakers" </> s "james-carlson")
        , Url.map (buildPage [ "speakers", "james-gary" ]) (s "speakers" </> s "james-gary")
        , Url.map (buildPage [ "speakers", "katie-hughes" ]) (s "speakers" </> s "katie-hughes")
        , Url.map (buildPage [ "speakers", "katja-mordaunt" ]) (s "speakers" </> s "katja-mordaunt")
        , Url.map (buildPage [ "speakers", "liz-krane" ]) (s "speakers" </> s "liz-krane")
        , Url.map (buildPage [ "speakers", "ryan-frazier" ]) (s "speakers" </> s "ryan-frazier")
        , Url.map (buildPage [ "speakers", "tessa-kelly" ]) (s "speakers" </> s "tessa-kelly")
        , Url.map (buildPage [ "sponsors" ]) (s "sponsors")
        , Url.map (buildPage [ "sponsorship" ]) (s "sponsorship")
        ] 

images =
    { elmLogo = (buildImage [ "elm-logo.svg" ])
    , speakers =
        { abadiKurniawan = (buildImage [ "speakers", "abadi-kurniawan.jpg" ])
        , brookeAngel = (buildImage [ "speakers", "brooke-angel.jpg" ])
        , ianMackenzie = (buildImage [ "speakers", "ian-mackenzie.jpeg" ])
        , jamesCarlson = (buildImage [ "speakers", "james-carlson.jpg" ])
        , jamesGary = (buildImage [ "speakers", "james-gary.jpg" ])
        , katieHughes = (buildImage [ "speakers", "katie-hughes.jpeg" ])
        , katjaMordaunt = (buildImage [ "speakers", "katja-mordaunt.jpg" ])
        , lizKrane = (buildImage [ "speakers", "liz-krane.jpg" ])
        , ryanFrazier = (buildImage [ "speakers", "ryan-frazier.jpg" ])
        , tessaKelly = (buildImage [ "speakers", "tessa-kelly.png" ])
        , all = [ (buildImage [ "speakers", "abadi-kurniawan.jpg" ]), (buildImage [ "speakers", "brooke-angel.jpg" ]), (buildImage [ "speakers", "ian-mackenzie.jpeg" ]), (buildImage [ "speakers", "james-carlson.jpg" ]), (buildImage [ "speakers", "james-gary.jpg" ]), (buildImage [ "speakers", "katie-hughes.jpeg" ]), (buildImage [ "speakers", "katja-mordaunt.jpg" ]), (buildImage [ "speakers", "liz-krane.jpg" ]), (buildImage [ "speakers", "ryan-frazier.jpg" ]), (buildImage [ "speakers", "tessa-kelly.png" ]) ]
        }
    , sponsors =
        { hubtran = (buildImage [ "sponsors", "hubtran.png" ])
        , all = [ (buildImage [ "sponsors", "hubtran.png" ]) ]
        }
    , waves = (buildImage [ "waves.svg" ])
    , all = [ (buildImage [ "elm-logo.svg" ]), (buildImage [ "waves.svg" ]) ]
    }

allImages : List (Path PathKey Path.ToImage)
allImages =
    [(buildImage [ "elm-logo.svg" ])
    , (buildImage [ "speakers", "abadi-kurniawan.jpg" ])
    , (buildImage [ "speakers", "brooke-angel.jpg" ])
    , (buildImage [ "speakers", "ian-mackenzie.jpeg" ])
    , (buildImage [ "speakers", "james-carlson.jpg" ])
    , (buildImage [ "speakers", "james-gary.jpg" ])
    , (buildImage [ "speakers", "katie-hughes.jpeg" ])
    , (buildImage [ "speakers", "katja-mordaunt.jpg" ])
    , (buildImage [ "speakers", "liz-krane.jpg" ])
    , (buildImage [ "speakers", "ryan-frazier.jpg" ])
    , (buildImage [ "speakers", "tessa-kelly.png" ])
    , (buildImage [ "sponsors", "hubtran.png" ])
    , (buildImage [ "waves.svg" ])
    ]


isValidRoute : String -> Result String ()
isValidRoute route =
    let
        validRoutes =
            List.map Path.toString all
    in
    if
        (route |> String.startsWith "http://")
            || (route |> String.startsWith "https://")
            || (route |> String.startsWith "#")
            || (validRoutes |> List.member route)
    then
        Ok ()

    else
        ("Valid routes:\n"
            ++ String.join "\n\n" validRoutes
        )
            |> Err


content : List ( List String, { extension: String, frontMatter : String, body : Maybe String } )
content =
    [ 
  ( ["404"]
    , { frontMatter = """{"title":"Page Not Found","description":"elm-conf is a one-day conference for the Elm programming language, returning September 12 2019 to St. Louis, MO."}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["about"]
    , { frontMatter = """{"title":"about elm-conf"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["cfp"]
    , { frontMatter = """{"title":"Propose a Talk","description":"elm-conf's call for submissions is open through May 17, 2019. We want your talk!"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["cfp", "proposals"]
    , { frontMatter = """{"title":"Your elm-conf 2019 Proposals"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["frequently-asked-questions"]
    , { frontMatter = """{"title":"Frequently Asked Questions"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( []
    , { frontMatter = """{"title":"elm-conf 2019","description":"elm-conf is a one-day conference for the Elm programming language, returning September 12 2019 to St. Louis, MO."}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["register"]
    , { frontMatter = """{"title":"Speaker Registration"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["schedule"]
    , { frontMatter = """{"title":"Speakers and Schedule","description":"elm-conf will take place September 12, 2019 at Union Station in St. Louis, MO as part of the Strange Loop preconference.","type":"schedule"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speak-at-elm-conf"]
    , { frontMatter = """{"title":"Speak at elm-conf","description":"elm-conf's call for submissions was open through May 19, 2019. We want your talk!"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["sponsors"]
    , { frontMatter = """{"title":"Sponsors"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["sponsorship"]
    , { frontMatter = """{"title":"Sponsor elm-conf"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "abadi-kurniawan"]
    , { frontMatter = """
|> Speaker
    name = Abadi Kurniawan
    photo = /images/speakers/abadi-kurniawan.jpg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "brooke-angel"]
    , { frontMatter = """
|> Speaker
    name = Brooke Angel
    photo = /images/speakers/brooke-angel.jpg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "ian-mackenzie"]
    , { frontMatter = """
|> Speaker
    name = Ian Mackenzie
    photo = /images/speakers/ian-mackenzie.jpeg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "james-carlson"]
    , { frontMatter = """
|> Speaker
    name = James Carlson
    photo = /images/speakers/james-carlson.jpg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "james-gary"]
    , { frontMatter = """
|> Speaker
    name = James Gary
    photo = /images/speakers/james-gary.jpg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "katie-hughes"]
    , { frontMatter = """
|> Speaker
    name = Katie Hughes
    photo = /images/speakers/katie-hughes.jpeg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "katja-mordaunt"]
    , { frontMatter = """
|> Speaker
    name = Katja Mordaunt
    photo = /images/speakers/katja-mordaunt.jpg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "liz-krane"]
    , { frontMatter = """
|> Speaker
    name = Liz Krane
    photo = /images/speakers/liz-krane.jpg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "ryan-frazier"]
    , { frontMatter = """
|> Speaker
    name = Ryan Frazier
    photo = /images/speakers/ryan-frazier.jpg
""" , body = Nothing
    , extension = "emu"
    } )
  ,
  ( ["speakers", "tessa-kelly"]
    , { frontMatter = """
|> Speaker
    name = Tessa Kelly
    photo = /images/speakers/tessa-kelly.png
""" , body = Nothing
    , extension = "emu"
    } )
  
    ]
