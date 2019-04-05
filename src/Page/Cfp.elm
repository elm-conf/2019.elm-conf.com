module Page.Cfp exposing (Env, Model, Msg(..), empty, init, update, view)

import Api.InputObject as ApiInputObject
import Api.Mutation as ApiMutation
import Api.Object as ApiObject
import Api.Object.CreateProposalPayload as ApiCreateProposalPayload
import Api.Object.Proposal as ApiProposal
import Api.Object.UpdateProposalPayload as ApiUpdateProposalPayload
import Api.Object.User as ApiUser
import Api.Query as ApiQuery
import Browser.Dom as Dom
import Browser.Navigation as Navigation
import Css
import Extra.String as String
import Graphql.Http as Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument as OptionalArg
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Lazy as Lazy
import Routes
import String.Verify
import Task
import Ui
import Ui.Button as Button
import Ui.TextArea as TextArea
import Ui.TextInput as TextInput exposing (textInput)
import Verify


type Msg
    = UpdateProposal Proposal
    | UpdateAuthor Author
    | PageLoaded (Maybe Int) (Maybe ( Proposal, Author ))
    | Submit
    | Submitted Bool
    | NoOp


type alias Author =
    { name : String
    , firstTime : Bool
    , underrepresented : Bool
    }


type alias Proposal =
    { abstract : String
    , title : String
    , pitch : String
    , outline : String
    , feedback : String
    }


newProposal : Proposal
newProposal =
    { abstract = ""
    , title = ""
    , pitch = ""
    , outline = ""
    , feedback = ""
    }


type alias LoadedModel =
    { proposal : Proposal
    , current : Maybe Int
    , errors : List String
    , author : Author
    }


type alias Env =
    { graphqlUrl : String
    , userId : Int
    , token : String
    , key : Navigation.Key
    }


type Model
    = Loading
    | Loaded LoadedModel
    | Failed


empty : Model
empty =
    Loading


loadPage : Env -> Maybe Int -> Cmd (Maybe ( Proposal, Author ))
loadPage env currentId =
    let
        proposalSelection : SelectionSet Proposal ApiObject.Proposal
        proposalSelection =
            SelectionSet.succeed Proposal
                |> SelectionSet.with ApiProposal.abstract
                |> SelectionSet.with ApiProposal.title
                |> SelectionSet.with ApiProposal.pitch
                |> SelectionSet.with ApiProposal.outline
                |> SelectionSet.with ApiProposal.feedback

        authorSelection : SelectionSet Author ApiObject.User
        authorSelection =
            SelectionSet.succeed Author
                |> SelectionSet.with ApiUser.name
                |> SelectionSet.with ApiUser.firstTimeSpeaker
                |> SelectionSet.with ApiUser.speakerUnderrepresented

        proposalQuerySelection : SelectionSet (Maybe Proposal) RootQuery
        proposalQuerySelection =
            case currentId of
                Just id ->
                    ApiQuery.proposal
                        { id = id }
                        proposalSelection

                Nothing ->
                    SelectionSet.succeed (Just newProposal)

        userQuerySelection : SelectionSet (Maybe Author) RootQuery
        userQuerySelection =
            ApiQuery.user
                { id = env.userId }
                authorSelection

        query : SelectionSet (Maybe ( Proposal, Author )) RootQuery
        query =
            SelectionSet.map2 (Maybe.map2 Tuple.pair)
                proposalQuerySelection
                userQuerySelection
    in
    Http.queryRequest env.graphqlUrl query
        |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
        |> Http.send (Result.toMaybe >> Maybe.andThen identity)


submitProposal : Env -> Maybe Int -> Author -> Proposal -> Cmd Bool
submitProposal env idToUpdate author proposal =
    case idToUpdate of
        Just proposalId ->
            SelectionSet.succeed ()
                |> ApiMutation.updateProposal
                    { input =
                        ApiInputObject.buildUpdateProposalInput
                            { patch =
                                ApiInputObject.buildProposalPatch
                                    (\patch ->
                                        { patch
                                            | title = OptionalArg.Present proposal.title
                                            , abstract = OptionalArg.Present proposal.abstract
                                            , pitch = OptionalArg.Present proposal.pitch
                                            , outline = OptionalArg.Present proposal.outline
                                            , feedback = OptionalArg.Present proposal.feedback
                                        }
                                    )
                            , id = proposalId
                            }
                            identity
                    }
                |> Http.mutationRequest env.graphqlUrl
                |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
                |> Http.send
                    (Result.toMaybe
                        >> Maybe.andThen identity
                        >> Maybe.map (\_ -> True)
                        >> Maybe.withDefault False
                    )

        Nothing ->
            SelectionSet.succeed ()
                |> ApiMutation.createProposal
                    { input =
                        ApiInputObject.buildCreateProposalInput
                            { proposal =
                                ApiInputObject.buildProposalInput
                                    { authorId = env.userId
                                    , title = proposal.title
                                    , abstract = proposal.abstract
                                    , pitch = proposal.pitch
                                    , outline = proposal.outline
                                    , feedback = proposal.feedback
                                    }
                            }
                            identity
                    }
                |> Http.mutationRequest env.graphqlUrl
                |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
                |> Http.send
                    (Result.toMaybe
                        >> Maybe.andThen identity
                        >> Maybe.map (\_ -> True)
                        >> Maybe.withDefault False
                    )


scrollToAbstract : Cmd ()
scrollToAbstract =
    Dom.getElement "section-Abstract"
        |> Task.andThen (\e -> Dom.setViewport 0 e.element.y)
        |> Task.attempt (\_ -> ())


init : Env -> Maybe Int -> ( Model, Cmd Msg )
init env currentId =
    ( Loading
    , loadPage env currentId
        |> Cmd.map (PageLoaded currentId)
    )


update : Env -> Msg -> Model -> ( Model, Cmd Msg )
update env msg model =
    case ( model, msg ) of
        ( Loading, PageLoaded _ Nothing ) ->
            ( Failed, Cmd.none )

        ( Loading, PageLoaded current (Just ( proposal, author )) ) ->
            ( Loaded
                { current = current
                , proposal = proposal
                , errors = []
                , author = author
                }
            , Cmd.none
            )

        ( Loaded m, UpdateProposal p ) ->
            ( Loaded { m | proposal = p }
            , Cmd.none
            )

        ( Loaded m, UpdateAuthor a ) ->
            ( Loaded { m | author = a }
            , Cmd.none
            )

        ( Loaded m, Submit ) ->
            case validator m.proposal of
                Ok valid ->
                    ( Loaded { m | errors = [] }
                    , submitProposal
                        env
                        m.current
                        m.author
                        valid
                        |> Cmd.map Submitted
                    )

                Err ( head, tail ) ->
                    ( Loaded { m | errors = head :: tail }
                    , Cmd.none
                    )

        ( Loaded m, Submitted True ) ->
            ( Loaded { m | errors = [] }
            , Navigation.pushUrl env.key <| Routes.path Routes.CfpProposals
            )

        ( Loaded m, Submitted False ) ->
            ( Loaded { m | errors = [ "Failed to submit. Please try again later." ] }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


boundedWords : Bool -> Int -> error -> Verify.Validator error String String
boundedWords max amount error input =
    let
        wordCount =
            String.wordCount input
    in
    if max && wordCount > amount then
        Err ( error, [] )

    else if not max && wordCount < amount then
        Err ( error, [] )

    else
        Ok input


validator : Verify.Validator String Proposal Proposal
validator =
    Verify.validate Proposal
        |> Verify.verify .abstract
            (Verify.compose
                (boundedWords True 200 "Please try to get your abstract below 200 words.")
                (boundedWords False 50 "Please provide a little more info in your abstract.")
            )
        |> Verify.verify .title (String.Verify.notBlank "Please give your talk a title.")
        |> Verify.verify .pitch
            (Verify.compose
                (boundedWords True 1000 "Please try to get your pitch below 1000 words.")
                (boundedWords False 50 "Please tell us a little bit more in your pitch.")
            )
        |> Verify.verify .outline
            (Verify.compose
                (boundedWords True 1000 "Please try to get your outline below 1000 words.")
                (boundedWords False 50 "Please give some more detail in your talk outline.")
            )
        |> Verify.keep .feedback


view : Model -> String -> Html Msg
view pageModel topContent =
    case pageModel of
        Loaded model ->
            viewEditor
                model
                topContent

        _ ->
            Html.text ""


viewEditor : LoadedModel -> String -> Html Msg
viewEditor ({ author, proposal } as model) topContent =
    Html.div []
        [ Ui.markdown topContent
        , Html.div []
            [ viewSection
                { label = "Contact Info"
                , heading = "About You"
                , description = "The talk selection team will not be able to see your name or email address. We would like to consider if you're a first-time speaker or a member of an underrepresented group, though, so we will be able to see that. If you're not comfortable revealing those things, please leave them unchecked."
                , hasBorder = True
                , inputs =
                    [ textInput "name"
                        |> TextInput.withLabel "Your Name"
                        |> TextInput.withPlaceholder "Cool Speaker Person"
                        |> TextInput.withValue author.name
                        |> TextInput.onInput (\name -> UpdateAuthor { author | name = name })
                        |> TextInput.view
                    , viewFirstTimeInput author.firstTime
                        |> Html.map (\firstTime -> UpdateAuthor { author | firstTime = firstTime })
                    , viewUnderrepresentedInput author.underrepresented
                        |> Html.map (\underrepresented -> UpdateAuthor { author | underrepresented = underrepresented })
                    ]
                }
            , viewSection
                { label = "Abstract"
                , heading = "Pitch your talk to the audience"
                , description = """
                  In conference parlance this is called the abstract. In no more than 200 words, tell us about your talk.
                  Like the title, remember to explain what your talk is about in a voice that communicates your style.
                  If you are speaking at elm-conf, then we know your talk will be exciting for the audience,
                  but we want them to know why they should be excited!
                  """
                , hasBorder = True
                , inputs =
                    [ TextArea.textarea "abstract"
                        |> TextArea.withValue proposal.abstract
                        |> TextArea.withPlaceholder "Abstract"
                        |> TextArea.withMaxWords 200
                        |> TextArea.onInput (\abstract -> UpdateProposal { proposal | abstract = abstract })
                        |> TextArea.view
                    ]
                }
            , viewSection
                { label = "Title"
                , heading = "Give your talk a title"
                , description = """
                  Now that the audience knows about your talk, what is it called? Try to name your talk something that
                  communicates both the topic of the talk and the style with which you will give it. That said, naming
                  is hard! Feel free to put something down for now and then request feedback on it below, or come back
                  to it later. You can even change it after it's accepted, right up until we print the schedules in
                  late August.
                  """
                , hasBorder = True
                , inputs =
                    [ TextInput.textInput "title"
                        |> TextInput.withPlaceholder "Super Neat Title"
                        |> TextInput.withValue proposal.title
                        |> TextInput.onInput (\title -> UpdateProposal { proposal | title = title })
                        |> TextInput.view
                    ]
                }
            , viewSection
                { label = "Pitch"
                , heading = "Pitch your talk to the organizers"
                , description = """
                  Explain why this particular talk will be valuable to the Elm community, and why you are the right
                  person to give it. You can do so without revealing you identity with phrases like "I am the author of
                  a library that does this", or "I have successfully applied this technique at a large company in the
                  automotive industry."

                  Only the organizers will see this, so it's OK to say exactly what you'll be speaking about. We'd
                  appreciate hearing more details on exactly what you plan to show; a vague pitch is much less likely to
                  be accepted than a specific one.
                  """
                , hasBorder = True
                , inputs =
                    [ TextArea.textarea "pitch"
                        |> TextArea.withValue proposal.pitch
                        |> TextArea.withPlaceholder "Pitch"
                        |> TextArea.withMaxWords 1000
                        |> TextArea.onInput (\pitch -> UpdateProposal { proposal | pitch = pitch })
                        |> TextArea.view
                    ]
                }
            , viewSection
                { label = "Outline"
                , heading = "How will you use your time on stage?"
                , description = """
                  All elm-conf talks will be 30 minutes. How do you plan to use that time? An outline would be most
                  useful here, but feel free to let us know however makes sense to you!

                  Note that you will not need to leave time for questions. We default to taking questions in the hall
                  after talks; it's a better experience for both the speakers and the attendees. Nobody's in the best
                  mindset to answer live questions after a talk, and it avoids wasting everyone's time with "well,
                  actually…"s.
                  """
                , hasBorder = True
                , inputs =
                    [ TextArea.textarea "outline"
                        |> TextArea.withValue proposal.outline
                        |> TextArea.withPlaceholder "Outline"
                        |> TextArea.withMaxWords 1000
                        |> TextArea.onInput (\outline -> UpdateProposal { proposal | outline = outline })
                        |> TextArea.view
                    ]
                }
            , viewSection
                { label = "Feedback"
                , heading = "What can we help you with?"
                , description = """
                  Writing proposals like this is difficult, especially if you haven't done many before! We want to make
                  that easier by working with you to improve your talk, as long as you make the initial submission before
                  May 1. So: what did you struggle with? Is there any part you think is weak?

                  Alternatively, if you would like us not to help, please say so here.
                  """
                , hasBorder = True
                , inputs =
                    [ TextArea.textarea "feedback"
                        |> TextArea.withValue proposal.feedback
                        |> TextArea.withPlaceholder "Request Feedback"
                        |> TextArea.withMaxWords 1000
                        |> TextArea.onInput (\feedback -> UpdateProposal { proposal | feedback = feedback })
                        |> TextArea.view
                    ]
                }
            , viewSection
                { label = "Send it in!"
                , heading =
                    if List.isEmpty model.errors then
                        "You're done!"

                    else
                        "Almost there..."
                , description =
                    if List.isEmpty model.errors then
                        """
                        Congratulations, you've finished your proposal! Once you submit, you'll receive a link in your inbox
                        to edit the talk. You can do so as many times as you like until May 15.

                        If you're submitting before May 1, you should hear from us about proposal feedback within a week.

                        Thank you so much for submitting your proposal. Talk to you soon!
                        """

                    else
                        "Have a look at the errors below to learn how to complete your proposal."
                , hasBorder = False
                , inputs =
                    [ case model.errors of
                        [] ->
                            Html.text ""

                        errors ->
                            errors
                                |> List.map (Html.text >> List.singleton >> Html.li [])
                                |> Html.styled Html.ul
                                    [ Ui.sansSerifFont
                                    , Css.color Ui.errorColor
                                    , Css.paddingLeft <| Css.em 1
                                    , Css.fontSize <| Css.px 18
                                    , Css.lineHeight <| Css.px 30
                                    ]
                                    []
                    , Button.button
                        |> Button.withLabel "Send it in!"
                        |> Button.onClick Submit
                        |> Button.view
                    ]
                }
            ]
        ]


viewFirstTimeInput : Bool -> Html Bool
viewFirstTimeInput =
    Lazy.lazy <|
        Ui.checkbox
            { name = "first_time"
            , label = "I am a first-time speaker"
            }


viewUnderrepresentedInput : Bool -> Html Bool
viewUnderrepresentedInput =
    Lazy.lazy <|
        Ui.checkbox
            { name = "underrepresented_group"
            , label = "I am a member of an underrepresented group"
            }


type alias Section msg =
    { label : String
    , heading : String
    , description : String
    , inputs : List (Html msg)
    , hasBorder : Bool
    }


viewSection : Section msg -> Html msg
viewSection section =
    Html.styled Html.div
        [ Css.property "display" "grid"
        , Css.property "grid-template-columns" "158px minmax(auto, 650px)"
        , Css.marginLeft <| Css.px -158
        ]
        [ Attributes.id <| "section-" ++ section.label ]
        [ Html.styled Html.div
            [ Css.property "display" "grid"
            , Css.property "grid-template-rows" "50px 1fr"
            ]
            []
            [ Html.styled Html.div
                [ Css.displayFlex
                , Css.property "align-self" "center"
                ]
                []
                [ Html.styled Html.div
                    [ Css.borderRadius <| Css.pct 50
                    , Css.border3 (Css.px 5) Css.solid Ui.primaryColor
                    , Css.backgroundColor <| Css.hex "FFF"
                    , Css.width <| Css.px 20
                    , Css.height <| Css.px 20
                    , Css.marginRight <| Css.px 4
                    ]
                    []
                    []
                , Html.styled Html.div
                    [ Ui.sansSerifFont
                    , Css.fontSize <| Css.px 18
                    , Css.color <| Css.hex "444444"
                    , Css.letterSpacing <| Css.px -0.6
                    ]
                    []
                    [ Html.text section.label ]
                ]
            , if section.hasBorder then
                Html.styled Html.div
                    [ Css.width <| Css.px 3
                    , Css.height <| Css.pct 100
                    , Css.borderRadius <| Css.px 1.5
                    , Css.backgroundColor <| Css.hex "D8D8D8"
                    , Css.marginLeft <| Css.px 8
                    ]
                    []
                    []

              else
                Html.text ""
            ]
        , Html.div []
            [ Html.styled Html.h2
                [ Css.color Ui.primaryColor
                , Css.margin Css.zero
                , Ui.serifFont
                , Css.fontSize <| Css.px 36
                , Css.lineHeight <| Css.px 50
                ]
                []
                [ Html.text section.heading ]
            , section.description
                |> String.split "\n\n"
                |> List.map
                    (Html.text
                        >> List.singleton
                        >> Html.styled Html.p
                            [ Css.margin2 (Css.px 30) Css.zero
                            , Css.fontSize <| Css.px 18
                            , Ui.sansSerifFont
                            , Css.lineHeight <| Css.px 30
                            ]
                            []
                    )
                |> Html.div []
            , section.inputs
                |> List.map
                    (List.singleton
                        >> Html.styled Html.div
                            [ Css.margin2 (Css.px 30) Css.zero
                            ]
                            []
                    )
                |> Html.div []
            ]
        ]
