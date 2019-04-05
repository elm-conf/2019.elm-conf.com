module Page.Cfp.Proposals exposing (Model, Msg(..), empty, load, update, view)

import Api.Object as Object
import Api.Object.Proposal as ApiProposal
import Api.Query as Query
import Css
import Graphql.Http as Http
import Graphql.SelectionSet as SelectionSet
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Routes
import Ui
import Url.Builder as Builder


type Model
    = Loading
    | Loaded LoadedModel
    | Failed (Http.Error (Maybe (List Proposal)))


type alias LoadedModel =
    { proposals : List Proposal }


type alias Proposal =
    { id : Int
    , title : String
    }


type alias Env =
    { graphqlUrl : String
    , token : String
    }


type Msg
    = GotProposals (Result (Http.Error (Maybe (List Proposal))) (Maybe (List Proposal)))


empty : Model
empty =
    Loading


load : Env -> ( Model, Cmd Msg )
load env =
    ( Loading
    , loadProposals env
    )


update : Env -> Msg -> Model -> ( Model, Cmd Msg )
update env msg model =
    case msg of
        GotProposals (Ok (Just proposals)) ->
            ( Loaded { proposals = proposals }
            , Cmd.none
            )

        GotProposals (Ok Nothing) ->
            ( Loaded { proposals = [] }
            , Cmd.none
            )

        GotProposals (Err err) ->
            ( Failed err
            , Cmd.none
            )


view : Model -> String -> Html Msg
view model topContent =
    case model of
        Loaded loadedModel ->
            viewList loadedModel topContent

        _ ->
            Html.text ""


viewList : LoadedModel -> String -> Html Msg
viewList { proposals } topContent =
    Html.main_ []
        [ Ui.markdown topContent
        , case proposals of
            [] ->
                Html.styled Html.p
                    [ Ui.bodyCopyStyle ]
                    []
                    [ Html.text "You haven't proposed any talks yet. Head on over to the "

                    -- TODO: this style doesn't match, but people shouldn't see
                    -- this until they submit so it's really a just-in-case
                    -- thing.
                    , Html.a [ Attributes.href (Routes.path Routes.Cfp []) ] [ Html.text "proposal page" ]
                    , Html.text " to get started"
                    ]

            _ ->
                proposals
                    |> List.map
                        (\{ title, id } ->
                            Html.styled Html.li
                                [ Ui.bodyCopyStyle
                                , Css.marginBottom (Css.px 5)
                                ]
                                []
                                [ Html.a
                                    [ Attributes.href <| Routes.path Routes.Cfp [ Builder.int "edit" id ] ]
                                    [ Html.text title ]
                                ]
                        )
                    |> Html.ul []
        ]


loadProposals : Env -> Cmd Msg
loadProposals env =
    SelectionSet.succeed Proposal
        |> SelectionSet.with ApiProposal.id
        |> SelectionSet.with ApiProposal.title
        -- query
        |> Query.proposals identity
        -- http
        |> Http.queryRequest env.graphqlUrl
        |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
        |> Http.send GotProposals
