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
import Css
import Graphql.Http as Http
import Graphql.OptionalArgument as OptionalArg
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html.Styled as Html exposing (Html)
import Html.Styled.Lazy as Lazy
import Regex
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
    | PageLoaded (Maybe ( Proposal, Author, List AvailableProposal ))
    | Submit
    | Submitted (Maybe AvailableProposal)
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


type alias AvailableProposal =
    { title : String
    , id : Int
    }


type alias LoadedModel =
    { current : ( Maybe Int, Proposal )
    , errors : List String
    , available : List AvailableProposal
    , author : Author
    }


type alias Env =
    { graphqlUrl : String
    , userId : Int
    , token : String
    }


type Model
    = Loading
    | Loaded LoadedModel
    | Failed


empty : Model
empty =
    Loading


loadPage : Env -> Maybe Int -> Cmd (Maybe ( Proposal, Author, List AvailableProposal ))
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

        availableProposalSelection : SelectionSet AvailableProposal ApiObject.Proposal
        availableProposalSelection =
            SelectionSet.succeed AvailableProposal
                |> SelectionSet.with ApiProposal.title
                |> SelectionSet.with ApiProposal.id

        authorSelection : SelectionSet Author ApiObject.User
        authorSelection =
            SelectionSet.succeed Author
                |> SelectionSet.with ApiUser.name
                |> SelectionSet.with ApiUser.firstTimeSpeaker
                |> SelectionSet.with ApiUser.speakerUnderrepresented

        userSelection : SelectionSet ( Proposal, Author, List AvailableProposal ) ApiObject.User
        userSelection =
            SelectionSet.succeed (\a b c -> ( a, b, c ))
                |> SelectionSet.with (SelectionSet.succeed newProposal)
                |> SelectionSet.with authorSelection
                |> SelectionSet.with
                    (ApiUser.authoredProposals
                        identity
                        availableProposalSelection
                    )
    in
    SelectionSet.succeed identity
        |> SelectionSet.with (ApiQuery.user { id = env.userId } userSelection)
        |> Http.queryRequest env.graphqlUrl
        |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
        |> Http.send (Result.toMaybe >> Maybe.andThen identity)


submitProposal : Env -> Maybe Int -> Author -> Proposal -> Cmd (Maybe AvailableProposal)
submitProposal env idToUpdate author proposal =
    let
        proposalSelection : SelectionSet Int ApiObject.Proposal
        proposalSelection =
            SelectionSet.succeed identity
                |> SelectionSet.with ApiProposal.id
    in
    case idToUpdate of
        Just proposalId ->
            SelectionSet.succeed identity
                |> SelectionSet.with (ApiUpdateProposalPayload.proposal proposalSelection)
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
                |> SelectionSet.map (Maybe.andThen identity)
                |> Http.mutationRequest env.graphqlUrl
                |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
                |> Http.send
                    (Result.toMaybe
                        >> Maybe.andThen identity
                        >> Maybe.map (AvailableProposal proposal.title)
                    )

        Nothing ->
            SelectionSet.succeed identity
                |> SelectionSet.with (ApiCreateProposalPayload.proposal proposalSelection)
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
                |> SelectionSet.map (Maybe.andThen identity)
                |> Http.mutationRequest env.graphqlUrl
                |> Http.withHeader "Authorization" ("Bearer " ++ env.token)
                |> Http.send
                    (Result.toMaybe
                        >> Maybe.andThen identity
                        >> Maybe.map (AvailableProposal proposal.title)
                    )


init : Env -> Maybe Int -> ( Model, Cmd Msg )
init env currentId =
    ( Loading
    , loadPage env currentId
        |> Cmd.map PageLoaded
    )


update : Env -> Msg -> Model -> ( Model, Cmd Msg )
update env msg model =
    case ( model, msg ) of
        ( Loading, PageLoaded Nothing ) ->
            ( Failed, Cmd.none )

        ( Loading, PageLoaded (Just ( current, author, available )) ) ->
            ( Loaded
                { current = ( Nothing, current )
                , errors = []
                , available = available
                , author = author
                }
            , Cmd.none
            )

        ( Loaded m, UpdateProposal p ) ->
            ( Loaded
                { m
                    | current =
                        Tuple.mapSecond
                            (\_ -> p)
                            m.current
                }
            , Cmd.none
            )

        ( Loaded m, UpdateAuthor a ) ->
            ( Loaded { m | author = a }
            , Cmd.none
            )

        ( Loaded m, Submit ) ->
            ( Loaded m
            , submitProposal
                env
                (Tuple.first m.current)
                m.author
                (Tuple.second m.current)
                |> Cmd.map Submitted
            )

        ( Loaded m, Submitted (Just a) ) ->
            ( Loaded { m | available = a :: m.available }
            , Dom.setViewport 0 0
                |> Task.perform (\_ -> NoOp)
            )

        ( Loaded m, Submitted Nothing ) ->
            ( Loaded { m | errors = [ "Failed to submit. Please try again later." ] }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


boundedWords : Bool -> Int -> error -> Verify.Validator error String String
boundedWords max amount error input =
    let
        splitRegex =
            "\\s+"
                |> Regex.fromStringWith { caseInsensitive = True, multiline = True }
                |> Maybe.withDefault Regex.never

        wordCount =
            input
                |> Regex.split splitRegex
                |> List.length
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
                (Tuple.second model.current)
                model.author
                topContent

        _ ->
            Html.text ""


viewEditor : Proposal -> Author -> String -> Html Msg
viewEditor proposal author topContent =
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
                , heading = "You're done!"
                , description = """
                  Congratulations, you've finished your proposal! Once you submit, you'll receive a link in your inbox
                  to edit the talk. You can do so as many times as you like until May 15.

                  If you're submitting before May 1, you should hear from us about proposal feedback within a week.

                  Thank you so much for submitting your proposal. Talk to you soon!
                  """
                , hasBorder = False
                , inputs =
                    [ Button.button
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
        []
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
