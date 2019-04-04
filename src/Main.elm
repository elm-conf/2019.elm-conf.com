port module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Navigation exposing (Key)
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Http
import Json.Decode as Decode exposing (Decoder, Value)
import Page.Cfp as Cfp
import Page.Register as Register
import Routes exposing (Route)
import Ui
import Url exposing (Url)
import Url.Parser exposing (parse)


port tokenChanges : (Maybe String -> msg) -> Sub msg


port setToken : Maybe String -> Cmd msg


type alias Page =
    { content : String
    , title : String
    }


type alias Model =
    { key : Key
    , route : Route
    , page : Maybe Page

    -- JWT
    , token : Maybe String

    -- graphql information
    , graphqlEndpoint : String

    -- application-y pages
    , cfp : Cfp.Model
    , register : Register.Model
    }


type alias Flags =
    { graphqlEndpoint : String
    , token : Value
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init { graphqlEndpoint, token } url key =
    let
        route =
            url
                |> parse Routes.parser
                |> Maybe.withDefault Routes.NotFound
    in
    onUrlChange url
        { key = key
        , page = Nothing
        , route = Routes.NotFound

        -- JWT
        , token =
            token
                |> Decode.decodeValue Decode.string
                |> Result.toMaybe

        -- graphql information
        , graphqlEndpoint = graphqlEndpoint

        -- application-y pages
        , cfp = Cfp.empty
        , register = Register.empty
        }


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | MarkdownRequestFinished (Result Http.Error String)
    | CfpChanged Cfp.Msg
    | RegisterChanged Register.Msg
    | TokenChanged (Maybe String)


onUrlChange : Url -> Model -> ( Model, Cmd Msg )
onUrlChange url model =
    let
        route =
            url
                |> parse Routes.parser
                |> Maybe.withDefault Routes.NotFound
    in
    case ( model.token, route ) of
        ( Nothing, Routes.Cfp ) ->
            ( model
            , Navigation.replaceUrl model.key <| Routes.path Routes.Register
            )

        _ ->
            ( { model
                | route = route
                , page = Nothing
              }
            , loadMarkdown route
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange url ->
            onUrlChange url model

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
                ( newRegister, cmds, result ) =
                    Register.update
                        { graphqlUrl = model.graphqlEndpoint }
                        registerMsg
                        model.register
            in
            case result of
                Register.Continue ->
                    ( { model | register = newRegister }
                    , Cmd.map RegisterChanged cmds
                    )

                Register.Registered token ->
                    ( { model | register = newRegister }
                    , setToken (Just token)
                    )

        TokenChanged (Just token) ->
            ( { model | token = Just token }
            , Navigation.pushUrl model.key <| Routes.path Routes.Cfp
            )

        TokenChanged Nothing ->
            ( { model | token = Nothing }
            , case model.route of
                Routes.Cfp ->
                    Navigation.pushUrl model.key <| Routes.path Routes.Register

                _ ->
                    Cmd.none
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


subscriptions : Model -> Sub Msg
subscriptions _ =
    tokenChanges TokenChanged


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        }
