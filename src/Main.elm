port module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Navigation exposing (Key)
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Http
import Json.Decode as Decode exposing (Decoder, Value)
import Page.Cfp as Cfp
import Page.Cfp.Proposals as Proposals
import Page.Register as Register
import Routes exposing (Route)
import Ui
import Url exposing (Url)
import Url.Parser as Parser exposing ((<?>), parse)
import Url.Parser.Query as Query


port tokenChanges : (Maybe Session -> msg) -> Sub msg


port setToken : Maybe String -> Cmd msg


type alias Page =
    { content : String
    , title : String
    }


type alias Session =
    { userId : Int
    , token : String
    }


type alias Model =
    { key : Key
    , route : Route
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
    , session : Value
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init { graphqlEndpoint, session } url key =
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
        , session =
            session
                |> Decode.decodeValue
                    (Decode.map2 Session
                        (Decode.field "userId" Decode.int)
                        (Decode.field "token" Decode.string)
                    )
                |> Debug.log "session"
                |> Result.toMaybe

        -- graphql information
        , graphqlEndpoint = graphqlEndpoint

        -- application-y pages
        , register = Register.empty
        , cfp = Cfp.empty
        , proposals = Proposals.empty
        }


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | MarkdownRequestFinished (Result Http.Error String)
    | RegisterChanged Register.Msg
    | SessionChanged (Maybe Session)
    | CfpMsg Cfp.Msg
    | ProposalsMsg Proposals.Msg


onUrlChange : Url -> Model -> ( Model, Cmd Msg )
onUrlChange url model =
    let
        route =
            url
                |> parse Routes.parser
                |> Maybe.withDefault Routes.NotFound
    in
    case ( model.session, route ) of
        ( Nothing, Routes.Cfp ) ->
            ( model
            , Navigation.replaceUrl model.key <| Routes.path Routes.Register []
            )

        ( Just session, Routes.Cfp ) ->
            let
                id : Maybe Int
                id =
                    Parser.custom "SUCCEED" (\_ -> Just ())
                        <?> Query.int "edit"
                        |> Parser.map (\_ id_ -> id_)
                        |> (\p -> Parser.parse p url)
                        |> Maybe.andThen identity

                ( newCfp, cmd ) =
                    Cfp.init
                        { graphqlUrl = model.graphqlEndpoint
                        , token = session.token
                        , userId = session.userId
                        , key = model.key
                        }
                        id
            in
            ( { model
                | cfp = newCfp
                , page = Nothing
                , route = route
              }
            , Cmd.batch
                [ loadMarkdown route
                , Cmd.map CfpMsg cmd
                ]
            )

        ( Nothing, Routes.CfpProposals ) ->
            ( model
            , Navigation.replaceUrl model.key <| Routes.path Routes.Register []
            )

        ( Just session, Routes.CfpProposals ) ->
            let
                ( newProposals, cmd ) =
                    Proposals.load
                        { graphqlUrl = model.graphqlEndpoint
                        , token = session.token
                        }
            in
            ( { model
                | page = Nothing
                , route = route
                , proposals = newProposals
              }
            , Cmd.batch
                [ loadMarkdown route
                , Cmd.map ProposalsMsg cmd
                ]
            )

        ( Just _, Routes.Register ) ->
            ( model
            , Navigation.replaceUrl model.key <| Routes.path Routes.Cfp []
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

        SessionChanged (Just session) ->
            ( { model | session = Just session }
            , Navigation.pushUrl model.key <| Routes.path Routes.Cfp []
            )

        SessionChanged Nothing ->
            ( { model | session = Nothing }
            , case model.route of
                Routes.Cfp ->
                    Navigation.pushUrl model.key <| Routes.path Routes.Register []

                _ ->
                    Cmd.none
            )

        CfpMsg cfpMsg ->
            case model.session of
                Just session ->
                    let
                        ( newCfp, cmd ) =
                            Cfp.update
                                { graphqlUrl = model.graphqlEndpoint
                                , token = session.token
                                , userId = session.userId
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
                Just session ->
                    let
                        ( newProposals, cmd ) =
                            Proposals.update
                                { graphqlUrl = model.graphqlEndpoint
                                , token = session.token
                                }
                                proposalsMsg
                                model.proposals
                    in
                    ( { model | proposals = newProposals }
                    , Cmd.map ProposalsMsg cmd
                    )

                Nothing ->
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
        let
            content =
                model.page
                    |> Maybe.map .content
                    |> Maybe.withDefault ""

            contentView =
                case model.route of
                    Routes.Cfp ->
                        Cfp.view model.cfp >> Html.map CfpMsg

                    Routes.CfpProposals ->
                        Proposals.view model.proposals >> Html.map ProposalsMsg

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
    tokenChanges SessionChanged


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
