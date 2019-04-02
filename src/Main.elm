module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Page.Index as Index
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
        [ case model.route of
            Routes.NotFound ->
                -- TODO: nice thing here
                Html.text "not found!"

            Routes.Index ->
                Index.view

            otherwise ->
                Html.text <| Routes.path model.route
        ]
            |> List.map Html.toUnstyled
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
