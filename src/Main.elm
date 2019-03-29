module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html exposing (Html)
import Url exposing (Url)


type alias Model =
    { key : Key }


type alias Flags =
    ()


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ _ key =
    ( { key = key }
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
    , body = [ Html.text "elm-conf 2019" ]
    }


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        }
