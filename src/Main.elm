port module Main exposing (main)

import Browser exposing (Document)
import Browser.Dom as Dom
import Browser.Navigation as Navigation exposing (Key)
import CfpJwt exposing (Token)
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Http
import Json.Decode as Decode exposing (Decoder, Value)
import Jwt exposing (JwtError)
import Page.Cfp as Cfp
import Page.Cfp.Proposals as Proposals
import Page.Register as Register
import Page.Schedule as Schedule
import Routes exposing (Route)
import Task
import Time
import Ui
import Url exposing (Url)
import Url.Parser as Parser exposing ((<?>), parse)
import Url.Parser.Query as Query


port tokenChanges : (Maybe String -> msg) -> Sub msg


port setToken : Maybe String -> Cmd msg


port removeToken : () -> Cmd msg


type alias Page =
    { content : String
    , title : String
    , photo : Maybe String
    }


type alias Session =
    ( String, CfpJwt.Token )


type alias Model =
    { key : Key
    , route : Maybe Route
    , page : Maybe Page

    -- JWT
    , session : Maybe Session

    -- graphql information
    , graphqlEndpoint : String

    -- application-y pages
    , register : Register.Model
    , cfp : Cfp.Model
    , proposals : Proposals.Model
    }


type alias Flags =
    { graphqlEndpoint : String
    , token : Maybe String
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init { graphqlEndpoint, token } url key =
    let
        route =
            url
                |> parse Routes.parser
                |> Maybe.withDefault Routes.NotFound

        session =
            CfpJwt.fromFlags token

        ( model, cmd ) =
            onUrlChange url
                { key = key
                , page = Nothing
                , route = Nothing

                -- JWT
                , session = session

                -- graphql information
                , graphqlEndpoint = graphqlEndpoint

                -- application-y pages
                , register = Register.empty
                , cfp = Cfp.empty
                , proposals = Proposals.empty
                }

        checkToken =
            case session of
                Just ( material, { expires } ) ->
                    Task.perform
                        (\now ->
                            if Time.posixToMillis now >= Time.posixToMillis expires then
                                TokenChanged Nothing

                            else
                                TokenWasFine
                        )
                        Time.now

                Nothing ->
                    Cmd.none
    in
    ( model
    , Cmd.batch [ checkToken, cmd ]
    )


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | MarkdownRequestFinished (Result Http.Error String)
    | RegisterChanged Register.Msg
    | TokenChanged (Maybe String)
    | CfpMsg Cfp.Msg
    | ProposalsMsg Proposals.Msg
    | TokenWasFine
    | SetFocus String
    | NoOp


onUrlChange : Url -> Model -> ( Model, Cmd Msg )
onUrlChange url model =
    let
        route =
            url
                |> parse Routes.parser
                |> Maybe.withDefault Routes.NotFound
    in
    if model.route == Just route then
        ( model, Cmd.none )

    else
        case ( model.session, route ) of
            ( _, Routes.Cfp ) ->
                ( model
                , Navigation.replaceUrl model.key <| Routes.path Routes.SpeakAtElmConf []
                )

            ( _, Routes.CfpProposals ) ->
                ( model
                , Navigation.replaceUrl model.key <| Routes.path Routes.SpeakAtElmConf []
                )

            ( _, Routes.Register ) ->
                ( model
                , Navigation.replaceUrl model.key <| Routes.path Routes.SpeakAtElmConf []
                )

            _ ->
                ( { model
                    | route = Just route
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
            if String.endsWith "pdf" url.path then
                ( model, Navigation.load (Url.toString url) )

            else
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

                Register.Authenticated token ->
                    ( { model | register = newRegister }
                    , setToken (Just token)
                    )

        TokenChanged (Just token) ->
            ( { model | session = CfpJwt.fromFlags (Just token) }
            , Navigation.pushUrl model.key <| Routes.path Routes.Cfp []
            )

        TokenChanged Nothing ->
            let
                routeCmd =
                    case model.route of
                        Just Routes.Cfp ->
                            Navigation.pushUrl model.key <| Routes.path Routes.Register []

                        _ ->
                            Cmd.none
            in
            ( { model | session = Nothing }
            , Cmd.batch [ routeCmd, removeToken () ]
            )

        CfpMsg cfpMsg ->
            case model.session of
                Just ( tokenMaterial, token ) ->
                    let
                        ( newCfp, cmd ) =
                            Cfp.update
                                { graphqlUrl = model.graphqlEndpoint
                                , token = tokenMaterial
                                , userId = token.userId
                                , key = model.key
                                }
                                cfpMsg
                                model.cfp
                    in
                    ( { model | cfp = newCfp }
                    , Cmd.map CfpMsg cmd
                    )

                Nothing ->
                    ( model, Cmd.none )

        ProposalsMsg proposalsMsg ->
            case model.session of
                Just ( tokenMaterial, _ ) ->
                    let
                        ( newProposals, cmd ) =
                            Proposals.update
                                { graphqlUrl = model.graphqlEndpoint
                                , token = tokenMaterial
                                }
                                proposalsMsg
                                model.proposals
                    in
                    ( { model | proposals = newProposals }
                    , Cmd.map ProposalsMsg cmd
                    )

                Nothing ->
                    ( model, Cmd.none )

        TokenWasFine ->
            ( model, Cmd.none )

        SetFocus toFocus ->
            ( model
            , Task.attempt
                (\_ -> NoOp)
                (Dom.focus toFocus)
            )

        NoOp ->
            ( model, Cmd.none )


loadMarkdown : Route -> Cmd Msg
loadMarkdown route =
    Http.get
        { url = Routes.markdown route
        , expect = Http.expectString MarkdownRequestFinished
        }


parsePage : String -> Maybe Page
parsePage raw =
    let
        decoder contentHolder =
            Decode.map2 contentHolder
                (Decode.field "title" Decode.string)
                (Decode.maybe (Decode.field "photo" Decode.string))
    in
    case String.split "---" raw of
        frontMatter :: rest ->
            frontMatter
                |> Decode.decodeString (decoder (Page (String.join "---" rest)))
                |> Result.toMaybe

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
                    Just Routes.Cfp ->
                        Cfp.view model.cfp >> Html.map CfpMsg

                    Just Routes.CfpProposals ->
                        Proposals.view model.proposals >> Html.map ProposalsMsg

                    Just Routes.Register ->
                        Register.view model.register >> Html.map RegisterChanged

                    Just Routes.Schedule ->
                        Schedule.view

                    _ ->
                        Ui.markdown
        in
        Ui.page
            { setFocus = SetFocus
            , photo = Maybe.andThen .photo model.page
            , content = contentView content
            }
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
