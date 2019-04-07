module Ui.TextArea exposing
    ( TextArea, textarea, view
    , withValue, onEvents, withMaxWords
    , withPlaceholder
    , withStyle
    )

{-|

@docs TextArea, textarea, view

@docs withValue, onEvents, withMaxWords

@docs withPlaceholder

@docs withStyle

-}

import Css exposing (Style)
import Extra.String as String
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Html.Styled.Lazy as Lazy
import Json.Encode exposing (null)
import Regex
import Ui


type TextArea msg
    = TextArea
        { name : String
        , value : Maybe String
        , placeholder : String
        , events :
            { input : String -> msg
            , blur : Maybe msg
            }
        , maxWords : Int
        , style : List Style
        }


textarea : String -> TextArea String
textarea name =
    TextArea
        { name = name
        , value = Nothing
        , placeholder = ""
        , events =
            { input = identity
            , blur = Nothing
            }
        , maxWords = 1000
        , style = []
        }


withValue : String -> TextArea msg -> TextArea msg
withValue value (TextArea config) =
    TextArea { config | value = Just value }


withPlaceholder : String -> TextArea msg -> TextArea msg
withPlaceholder placeholder (TextArea config) =
    TextArea { config | placeholder = placeholder }


onEvents :
    { input : String -> msgB
    , blur : Maybe msgB
    }
    -> TextArea msgA
    -> TextArea msgB
onEvents events (TextArea config) =
    TextArea
        { name = config.name
        , value = config.value
        , placeholder = config.placeholder
        , maxWords = config.maxWords
        , style = config.style

        -- the new one, of a new type...
        , events = events
        }


withStyle : List Style -> TextArea msg -> TextArea msg
withStyle style (TextArea config) =
    TextArea { config | style = style }


withMaxWords : Int -> TextArea msg -> TextArea msg
withMaxWords maxWords (TextArea config) =
    TextArea { config | maxWords = maxWords }


view : TextArea msg -> Html msg
view ((TextArea config) as input_) =
    case config.value of
        Just value ->
            Lazy.lazy (baseView input_) value

        Nothing ->
            baseView input_ ""


baseView : TextArea msg -> String -> Html msg
baseView (TextArea config) value =
    let
        count =
            String.wordCount value
    in
    Html.styled Html.div
        config.style
        []
        [ Html.styled Html.textarea
            [ Css.height <| Css.px 40
            , Css.border3 (Css.px 1) Css.solid (Css.hex "444444")
            , Css.borderRadius <| Css.px 5
            , Css.padding2 (Css.px 14) Css.zero
            , Css.paddingLeft <| Css.px 16
            , Css.fontSize <| Css.px 18
            , Css.width <| Css.pct 100
            , Css.minHeight <| Css.px 150
            , Css.display Css.block
            , Css.resize Css.vertical
            , Css.outline Css.zero
            , Ui.sansSerifFont
            , Css.focus
                [ Css.borderColor Ui.primaryColor
                , Css.property "caret-color" <| Ui.primaryColor.value
                ]
            ]
            [ Attributes.value value
            , Attributes.name config.name
            , Attributes.placeholder config.placeholder

            -- events
            , Events.onInput config.events.input
            , case config.events.blur of
                Just msg ->
                    Events.onBlur msg

                Nothing ->
                    Attributes.property "Ui.TextArea.onBlur" null
            ]
            []
        , Html.styled Html.div
            [ Ui.sansSerifFont
            , Css.fontSize <| Css.px 14
            , Css.color <| Css.hex "444444"
            , Css.marginTop <| Css.px 5
            ]
            []
            [ Html.text <|
                String.fromInt count
                    ++ " / "
                    ++ String.fromInt config.maxWords
                    ++ " words"
            ]
        ]
