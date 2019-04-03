module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Http
import Json.Decode as Decode exposing (Decoder)
import Routes exposing (Route)
import Ui
import Url exposing (Url)
import Url.Parser exposing (parse)


type alias Page =
    { content : String
    , title : String
    }


type alias Model =
    { key : Key
    , route : Route
    , page : Maybe Page
    }


type alias Flags =
    ()


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    let
        route =
            url
                |> parse Routes.parser
                |> Maybe.withDefault Routes.NotFound
    in
    ( { key = key
      , page = Nothing
      , route = route
      }
    , loadMarkdown route
    )


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | MarkdownRequestFinished (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange url ->
            let
                route =
                    url
                        |> parse Routes.parser
                        |> Maybe.withDefault Routes.NotFound
            in
            ( { model
                | route = route
                , page = Nothing
              }
            , loadMarkdown route
            )

        MarkdownRequestFinished result ->
            ( { model
                | page =
                    result
                        |> Result.toMaybe
                        |> Maybe.andThen parsePage
              }
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


parsePage : String -> Maybe Page
parsePage raw =
    case String.split "---" raw of
        frontMatter :: rest ->
            frontMatter
                |> Decode.decodeString (Decode.field "title" Decode.string)
                |> Result.toMaybe
                |> Maybe.map (Page (String.join "---" rest))

        _ ->
            Nothing


view : Model -> Document Msg
view model =
    { title =
        model.page
            |> Maybe.map .title
            |> Maybe.withDefault ""
    , body =
        [ model.page
            |> Maybe.map .content
            |> Maybe.withDefault ""
            |> Ui.Markdown
            |> Ui.page
            |> Html.toUnstyled
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
