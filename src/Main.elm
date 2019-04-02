module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Http
import Routes exposing (Route)
import Ui
import Url exposing (Url)
import Url.Parser exposing (parse)


type alias Model =
    { key : Key
    , route : Route
    , markdown : Maybe String
    }


type alias Flags =
    ()


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    let
        route =
            parse Routes.parser url
    in
    ( { key = key
      , markdown = Nothing
      , route = Maybe.withDefault Routes.NotFound route
      }
    , route
        |> Maybe.map loadMarkdown
        |> Maybe.withDefault Cmd.none
    )


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | MarkdownRequestFinished (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange url ->
            case parse Routes.parser url of
                Just route ->
                    ( { model
                        | route = route
                        , markdown = Nothing
                      }
                    , loadMarkdown route
                    )

                Nothing ->
                    ( { model | route = Routes.NotFound }
                    , Cmd.none
                    )

        MarkdownRequestFinished result ->
            ( { model | markdown = Result.toMaybe result }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


loadMarkdown : Route -> Cmd Msg
loadMarkdown route =
    Http.get
        { url = Routes.markdown route
        , expect = Http.expectString MarkdownRequestFinished
        }


view : Model -> Document Msg
view model =
    { title = "TODO"
    , body =
        [ case model.route of
            Routes.NotFound ->
                -- TODO: nice thing here
                Html.text "not found!"

            otherwise ->
                model.markdown
                    |> Maybe.withDefault ""
                    |> Ui.Markdown
                    |> Ui.page
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
