module Page.Cfp exposing (Model, empty, view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Lazy as Lazy
import Regex
import String.Verify
import Ui
import Verify


type alias Model =
    { name : String
    , email : String
    , firstTime : Bool
    , underrepresentedGroup : Bool
    , abstract : String
    , title : String
    , outline : String
    , feedbackRequest : String
    }


empty : Model
empty =
    { name = ""
    , email = ""
    , firstTime = False
    , underrepresentedGroup = False
    , abstract = ""
    , title = ""
    , outline = ""
    , feedbackRequest = ""
    }


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


validator : Verify.Validator String Model Model
validator =
    Verify.validate Model
        |> Verify.verify .name (String.Verify.notBlank "Please enter your name. We need it to get in touch with you if your talk is selected.")
        |> Verify.verify .email (String.Verify.notBlank "Please enter your email address. We need it to get in touch with you if your talk is selected.")
        |> Verify.keep .firstTime
        |> Verify.keep .underrepresentedGroup
        |> Verify.verify .abstract
            (Verify.compose
                (boundedWords True 1000 "Please try to get your abstract below 1000 words.")
                (boundedWords False 50 "Please tell us a little bit more about your talk.")
            )
        |> Verify.verify .title (String.Verify.notBlank "Please give your talk a title.")
        |> Verify.verify .outline
            (Verify.compose
                (boundedWords True 1000 "Please try to get your outline below 1000 words.")
                (boundedWords False 50 "Please give some more detail in your talk outline.")
            )
        |> Verify.keep .feedbackRequest


view : Model -> String -> Html Model
view model topContent =
    Html.div []
        [ Ui.markdown topContent
        , Html.div []
            [ viewSection
                { label = "Contact Info"
                , heading = "About You"
                , description = "The talk selection team will not be able to see your name or email address. We would like to consider if you're a first-time speaker or a member of an underrepresented group, though, so we will be able to see that. If you're not comfortable revealing those things, please leave them unchecked."
                , hasBorder = True
                , inputs =
                    [ viewNameInput model.name
                        |> Html.map (\name -> { model | name = name })
                    , viewEmailInput model.email
                        |> Html.map (\email -> { model | email = email })
                    , viewFirstTimeInput model.firstTime
                        |> Html.map (\firstTime -> { model | firstTime = firstTime })
                    , viewUnderrepresentedInput model.underrepresentedGroup
                        |> Html.map (\underrepresentedGroup -> { model | underrepresentedGroup = underrepresentedGroup })
                    ]
                }
            ]
        ]


viewNameInput : String -> Html String
viewNameInput =
    Lazy.lazy <|
        Ui.textInput
            { name = "name"
            , label = Just "Your Name"
            , placeholder = "Cool Speaker Person"
            }


viewEmailInput : String -> Html String
viewEmailInput =
    Lazy.lazy <|
        Ui.textInput
            { name = "email"
            , label = Just "Your Email Address"
            , placeholder = "you@awesomeperson.com"
            }


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
