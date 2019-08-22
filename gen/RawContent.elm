module RawContent exposing (content)

import Dict exposing (Dict)


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
  ( ["speakers", "abadi-kurniawan"]
    , { frontMatter = """{"title":"Abadi Kurniawan","photo":"/images/speakers/abadi-kurniawan.jpg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "brooke-angel"]
    , { frontMatter = """{"title":"Brooke Angel","photo":"/images/speakers/brooke-angel.jpg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "ian-mackenzie"]
    , { frontMatter = """{"title":"Ian Mackenzie","photo":"/images/speakers/ian-mackenzie.jpeg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "james-carlson"]
    , { frontMatter = """{"title":"James Carlson","photo":"/images/speakers/james-carlson.jpg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "james-gary"]
    , { frontMatter = """{"title":"James Gary","photo":"/images/speakers/james-gary.jpg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "katie-hughes"]
    , { frontMatter = """{"title":"Katie Hughes","photo":"/images/speakers/katie-hughes.jpeg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "katja-mordaunt"]
    , { frontMatter = """{"title":"Katja Mordaunt","photo":"/images/speakers/katja-mordaunt.jpg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "liz-krane"]
    , { frontMatter = """{"title":"Liz Krane","photo":"/images/speakers/liz-krane.jpg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "ryan-frazier"]
    , { frontMatter = """{"title":"Ryan Frazier","photo":"/images/speakers/ryan-frazier.jpg"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["speakers", "tessa-kelly"]
    , { frontMatter = """{"title":"Tessa Kelly","photo":"/images/speakers/tessa-kelly.png"}
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
  
    ]
    