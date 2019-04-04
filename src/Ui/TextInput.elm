module Ui.TextInput exposing
    ( Input, input, view
    , withValue
    , withPlaceholder
    , withLabel
    , InputType(..), withType
    , onInput
    )

{-|

@docs Input, input, view

@docs withValue

@docs withPlaceholder

@docs withLabel

@docs InputType, withType

@docs onInput

-}

import Css
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Html.Styled.Lazy as Lazy
import Ui


type Input msg
    = Input
        { name : String
        , value : Maybe String
        , placeholder : String
        , label : Maybe String
        , type_ : InputType
        , onInput : String -> msg
        }


input : String -> Input String
input name =
    Input
        { name = name
        , value = Nothing
        , placeholder = ""
        , label = Nothing
        , type_ = Text
        , onInput = identity
        }


withValue : String -> Input msg -> Input msg
withValue value (Input config) =
    Input { config | value = Just value }


withPlaceholder : String -> Input msg -> Input msg
withPlaceholder placeholder (Input config) =
    Input { config | placeholder = placeholder }


withLabel : String -> Input msg -> Input msg
withLabel label (Input config) =
    Input { config | label = Just label }


type InputType
    = Text
    | Email
    | Password


withType : InputType -> Input msg -> Input msg
withType type_ (Input config) =
    Input { config | type_ = type_ }


onInput : (String -> msgB) -> Input msgA -> Input msgB
onInput onInput_ (Input config) =
    Input
        { name = config.name
        , value = config.value
        , placeholder = config.placeholder
        , label = config.label
        , type_ = config.type_
        , onInput = onInput_
        }


view : Input msg -> Html msg
view ((Input config) as input_) =
    case config.value of
        Just value ->
            Lazy.lazy (baseView input_) value

        Nothing ->
            baseView input_ ""


baseView : Input msg -> String -> Html msg
baseView (Input config) value =
    Html.div []
        [ case config.label of
            Just label ->
                Html.styled Html.label
                    [ Ui.sansSerifFont
                    , Css.color <| Css.hex "444444"
                    , Css.fontSize <| Css.px 14
                    , Css.display Css.block
                    , Css.marginBottom <| Css.px 4
                    ]
                    [ Attributes.for config.name ]
                    [ Html.text label ]

            Nothing ->
                Html.text ""
        , Html.styled Html.input
            [ Css.height <| Css.px 40
            , Css.border3 (Css.px 1) Css.solid (Css.hex "444444")
            , Css.borderRadius <| Css.px 5
            , Css.lineHeight <| Css.px 38
            , Css.paddingLeft <| Css.px 16
            , Css.fontSize <| Css.px 18
            , Css.width <| Css.pct 100
            , Css.display Css.block
            , Css.outline Css.zero
            , Ui.sansSerifFont
            , Css.focus
                [ Css.borderColor Ui.primaryColor
                , Css.property "caret-color" <| Ui.primaryColor.value
                ]
            ]
            [ inputTypeToAttr config.type_
            , Attributes.value value
            , Attributes.name config.name
            , Attributes.placeholder config.placeholder
            , Events.onInput config.onInput
            ]
            []
        ]


inputTypeToAttr : InputType -> Attribute msg
inputTypeToAttr inputType =
    case inputType of
        Text ->
            Attributes.type_ "text"

        Email ->
            Attributes.type_ "email"

        Password ->
            Attributes.type_ "password"
