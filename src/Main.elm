module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Navigation exposing (Key)
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Http
import Json.Decode as Decode exposing (Decoder)
import Page.Cfp as Cfp
import Page.Register as Register
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

    -- application-y pages
    , cfp : Cfp.Model
    , register : Register.Model
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
      , cfp = Cfp.empty
      , register = Register.empty
      }
    , loadMarkdown route
    )


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | MarkdownRequestFinished (Result Http.Error String)
    | CfpChanged Cfp.Msg
    | RegisterChanged Register.Msg


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

        UrlRequest (Browser.Internal url) ->
            ( model
            , Navigation.pushUrl model.key (Url.toString url)
            )

        UrlRequest (Browser.External url) ->
            ( model
            , Navigation.load url
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

        CfpChanged (Cfp.Update cfp) ->
            ( { model | cfp = cfp }
            , Cmd.none
            )

        CfpChanged Cfp.Submit ->
            ( model, Cmd.none )

        RegisterChanged registerMsg ->
            let
                ( newRegister, cmds ) =
                    Register.update registerMsg model.register
            in
            ( { model | register = newRegister }
            , Cmd.map RegisterChanged cmds
            )


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
        let
            content =
                model.page
                    |> Maybe.map .content
                    |> Maybe.withDefault ""

            contentView =
                case model.route of
                    Routes.Cfp ->
                        Cfp.view model.cfp >> Html.map CfpChanged

                    Routes.Register ->
                        Register.view model.register >> Html.map RegisterChanged

                    _ ->
                        Ui.markdown
        in
        contentView content
            |> Ui.page
            |> Html.toUnstyled
            |> List.singleton
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
