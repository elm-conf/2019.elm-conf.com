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
import Task
import Ui
import Ui.Button as Button
import Ui.TextArea as TextArea
import Ui.TextInput as TextInput exposing (textInput)
import ValidatedString exposing (ValidatedString)


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
    { abstract : ValidatedString
    , title : ValidatedString
    , pitch : ValidatedString
    , outline : ValidatedString
    , feedback : String
    }


newProposal : Proposal
newProposal =
    { abstract = validatedAbstract ""
    , title = validatedTitle ""
    , pitch = validatedPitch ""
    , outline = validatedOutline ""
    , feedback = ""
    }


proposalErrors : Proposal -> List String
proposalErrors { abstract, title, pitch, outline } =
    List.filterMap ValidatedString.error
        [ abstract, title, pitch, outline ]


validatedAbstract : String -> ValidatedString
validatedAbstract =
    ValidatedString.fromString
        >> ValidatedString.withMaxWords 200 "Please try to get your abstract below 200 words."
        >> ValidatedString.withMinWords 50 "Please provide a little more info in your abstract."


validatedTitle : String -> ValidatedString
validatedTitle =
    ValidatedString.fromString
        >> ValidatedString.withNotBlank "Please give your talk a title."


validatedPitch : String -> ValidatedString
validatedPitch =
    ValidatedString.fromString
        >> ValidatedString.withMaxWords 1000 "Please try to get your pitch below 1000 words."
        >> ValidatedString.withMinWords 50 "Please tell us a little more in your pitch."


validatedOutline : String -> ValidatedString
validatedOutline =
    ValidatedString.fromString
        >> ValidatedString.withMaxWords 1000 "Please try to get your outline below 1000 words."
        >> ValidatedString.withMinWords 50 "Please give some more detail in your outline."


type alias LoadedModel =
    { proposal : Proposal
    , current : Maybe Int
    , error : Maybe String
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
                |> SelectionSet.with (SelectionSet.map validatedAbstract ApiProposal.abstract)
                |> SelectionSet.with (SelectionSet.map validatedTitle ApiProposal.title)
                |> SelectionSet.with (SelectionSet.map validatedPitch ApiProposal.pitch)
                |> SelectionSet.with (SelectionSet.map validatedOutline ApiProposal.outline)
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
    let
        updateUser =
            SelectionSet.succeed ()
                |> ApiMutation.updateUser
                    { input =
                        ApiInputObject.buildUpdateUserInput
                            { id = env.userId
                            , patch =
                                ApiInputObject.buildUserPatch
                                    (\patch ->
                                        { patch
                                            | name = OptionalArg.Present author.name
                                            , speakerUnderrepresented = OptionalArg.Present author.underrepresented
                                            , firstTimeSpeaker = OptionalArg.Present author.firstTime
                                        }
                                    )
                            }
                            identity
                    }
    in
    case idToUpdate of
        Just proposalId ->
            SelectionSet.succeed (Maybe.map2 (\_ _ -> ()))
                |> SelectionSet.with
                    (ApiMutation.updateProposal
                        { input =
                            ApiInputObject.buildUpdateProposalInput
                                { patch =
                                    ApiInputObject.buildProposalPatch
                                        (\patch ->
                                            { patch
                                                | title = OptionalArg.Present (ValidatedString.toString proposal.title)
                                                , abstract = OptionalArg.Present (ValidatedString.toString proposal.abstract)
                                                , pitch = OptionalArg.Present (ValidatedString.toString proposal.pitch)
                                                , outline = OptionalArg.Present (ValidatedString.toString proposal.outline)
                                                , feedback = OptionalArg.Present proposal.feedback
                                            }
                                        )
                                , id = proposalId
                                }
                                identity
                        }
                        (SelectionSet.succeed ())
                    )
                |> SelectionSet.with updateUser
                |> Http.mutationRequest env.graphqlUrl
                |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
                |> Http.send
                    (Result.toMaybe
                        >> Maybe.andThen identity
                        >> Maybe.map (\_ -> True)
                        >> Maybe.withDefault False
                    )

        Nothing ->
            SelectionSet.succeed (Maybe.map2 (\_ _ -> ()))
                |> SelectionSet.with
                    (ApiMutation.createProposal
                        { input =
                            ApiInputObject.buildCreateProposalInput
                                { proposal =
                                    ApiInputObject.buildProposalInput
                                        { authorId = env.userId
                                        , title = ValidatedString.toString proposal.title
                                        , abstract = ValidatedString.toString proposal.abstract
                                        , pitch = ValidatedString.toString proposal.pitch
                                        , outline = ValidatedString.toString proposal.outline
                                        , feedback = proposal.feedback
                                        }
                                }
                                identity
                        }
                        (SelectionSet.succeed ())
                    )
                |> SelectionSet.with updateUser
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
                , error = Nothing
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
            let
                oldProposal =
                    m.proposal

                validatedProposal =
                    { oldProposal
                        | abstract = ValidatedString.validate oldProposal.abstract
                        , title = ValidatedString.validate oldProposal.title
                        , pitch = ValidatedString.validate oldProposal.pitch
                        , outline = ValidatedString.validate oldProposal.outline
                    }

                newModel =
                    { m | proposal = validatedProposal }
            in
            ( Loaded newModel
            , case proposalErrors newModel.proposal of
                [] ->
                    newModel.proposal
                        |> submitProposal env m.current m.author
                        |> Cmd.map Submitted

                _ ->
                    Cmd.none
            )

        ( Loaded m, Submitted True ) ->
            ( Loaded { m | error = Nothing }
            , Navigation.pushUrl env.key <| Routes.path Routes.CfpProposals []
            )

        ( Loaded m, Submitted False ) ->
            ( Loaded { m | error = Just "Failed to submit. Please try again later." }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


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
                        |> TextInput.onEvents
                            { input = \name -> UpdateAuthor { author | name = name }
                            , blur = Nothing
                            }
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
                        |> TextArea.withValue (ValidatedString.toString proposal.abstract)
                        |> TextArea.withPlaceholder "Abstract"
                        |> TextArea.withMaxWords 200
                        |> TextArea.onEvents
                            { input = \abstract -> UpdateProposal { proposal | abstract = ValidatedString.input abstract proposal.abstract }
                            , blur = Just (UpdateProposal { proposal | abstract = ValidatedString.validate proposal.abstract })
                            }
                        |> TextArea.withError (ValidatedString.error proposal.abstract)
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
                        |> TextInput.withValue (ValidatedString.toString proposal.title)
                        |> TextInput.onEvents
                            { input = \title -> UpdateProposal { proposal | title = ValidatedString.input title proposal.title }
                            , blur = Just (UpdateProposal { proposal | title = ValidatedString.validate proposal.title })
                            }
                        |> TextInput.withError (ValidatedString.error proposal.title)
                        |> TextInput.view
                    ]
                }
            , viewSection
                { label = "Pitch"
                , heading = "Pitch your talk to the organizers"
                , description = """
                  Explain why this particular talk will be valuable to the Elm community, and why you are the right
                  person to give it. You can do so without revealing your identity with phrases like "I am the author of
                  a library that does this", or "I have successfully applied this technique at a large company in the
                  automotive industry."

                  Only the organizers will see this, so it's OK to say exactly what you'll be speaking about. We'd
                  appreciate hearing more details on exactly what you plan to show; a vague pitch is much less likely to
                  be accepted than a specific one.
                  """
                , hasBorder = True
                , inputs =
                    [ TextArea.textarea "pitch"
                        |> TextArea.withValue (ValidatedString.toString proposal.pitch)
                        |> TextArea.withPlaceholder "Pitch"
                        |> TextArea.withMaxWords 1000
                        |> TextArea.onEvents
                            { input = \pitch -> UpdateProposal { proposal | pitch = ValidatedString.input pitch proposal.pitch }
                            , blur = Just (UpdateProposal { proposal | pitch = ValidatedString.validate proposal.pitch })
                            }
                        |> TextArea.withError (ValidatedString.error proposal.pitch)
                        |> TextArea.view
                    ]
                }
            , viewSection
                { label = "Outline"
                , heading = "How will you use your time on stage?"
                , description = """
                  All elm-conf talks will be 30 minutes.
                  How do you plan to use that time?
                  An outline would be most useful here, but feel free to let us know however makes sense to you!

                  Note that you will not need to leave time for questions.
                  We will make time to take questions in the hall after talks; it's a better experience for both the speakers and the attendees.
                  Nobody's in the best mindset to answer live questions after a talk, and it avoids wasting everyone's time with "well, actually…"s.
                  """
                , hasBorder = True
                , inputs =
                    [ TextArea.textarea "outline"
                        |> TextArea.withValue (ValidatedString.toString proposal.outline)
                        |> TextArea.withPlaceholder "Outline"
                        |> TextArea.withMaxWords 1000
                        |> TextArea.onEvents
                            { input = \outline -> UpdateProposal { proposal | outline = ValidatedString.input outline proposal.outline }
                            , blur = Just (UpdateProposal { proposal | outline = ValidatedString.validate proposal.outline })
                            }
                        |> TextArea.withError (ValidatedString.error proposal.outline)
                        |> TextArea.view
                    ]
                }
            , viewSection
                { label = "Feedback"
                , heading = "What can we help you with?"
                , description = """
                  Writing proposals like this is difficult, especially if you haven't done many before! We want to make
                  that easier by working with you to improve your talk, as long as you make the initial submission before
                  May 12. So: what did you struggle with? Is there any part you think is weak?

                  Alternatively, if you would like us not to help, please say so here.
                  """
                , hasBorder = True
                , inputs =
                    [ TextArea.textarea "feedback"
                        |> TextArea.withValue proposal.feedback
                        |> TextArea.withPlaceholder "Request Feedback"
                        |> TextArea.withMaxWords 1000
                        |> TextArea.onEvents
                            { input = \feedback -> UpdateProposal { proposal | feedback = feedback }
                            , blur = Nothing
                            }
                        |> TextArea.view
                    ]
                }
            , let
                modelErrors =
                    model.error
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []

                errors =
                    modelErrors ++ proposalErrors model.proposal
              in
              viewSection
                { label = "Send it in!"
                , heading =
                    if List.isEmpty errors then
                        "You're done!"

                    else
                        "Almost there..."
                , description =
                    if List.isEmpty errors then
                        """
                        Congratulations, you've finished your proposal!
                        Once you submit, you can use this site to edit this proposal.
                        You can do so as many times as you like until May 19.

                        If you're submitting before May 12, you should hear from us about proposal feedback within a week.

                        Thank you so much for submitting your proposal. Talk to you soon!
                        """

                    else
                        "Have a look at the errors below to learn how to complete your proposal."
                , hasBorder = False
                , inputs =
                    [ case errors of
                        [] ->
                            Html.text ""

                        _ ->
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
            , label = "I am a first-time conference speaker"
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
        [ Ui.desktopOnly
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "158px minmax(auto, 650px)"
            , Css.marginLeft <| Css.px -158
            ]
        ]
        [ Attributes.id <| "section-" ++ section.label ]
        [ Html.styled Html.div
            [ Ui.desktopOnly
                [ Css.property "display" "grid"
                , Css.property "grid-template-rows" "50px 1fr"
                ]
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
                    [ Ui.responsive
                        { desktop =
                            [ Css.width <| Css.px 3
                            , Css.height <| Css.pct 100
                            , Css.borderRadius <| Css.px 1.5
                            , Css.backgroundColor <| Css.hex "D8D8D8"
                            , Css.marginLeft <| Css.px 8
                            ]
                        , mobile = [ Css.display Css.none ]
                        }
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
