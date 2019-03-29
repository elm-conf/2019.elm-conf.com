module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html exposing (Html)
import Routes exposing (Route)
import Url exposing (Url)
import Url.Parser exposing (parse)


type alias Model =
    { key : Key
    , route : Route
    }


type alias Flags =
    ()


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , route =
            url
                |> parse Routes.parser
                |> Maybe.withDefault Routes.NotFound
      }
    , Cmd.none
    )


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model
    , Cmd.none
    )


view : Model -> Document Msg
view model =
    { title = "TODO"
    , body =
        [ Html.text "elm-conf 2019"
        , case model.route of
            Routes.NotFound ->
                -- TODO: nice thing here
                Html.text "not found!"

            otherwise ->
                Html.text <| Routes.path model.route
        ]
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        }
