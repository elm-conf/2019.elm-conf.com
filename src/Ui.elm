module Ui exposing
    ( Checkbox
    , bodyCopyStyle
    , buttonStyle
    , checkbox
    , errorColor
    , linkStyle
    , markdown
    , page
    , primaryColor
    , sansSerifFont
    , serifFont
    )

import Css
import Css.Global as Global
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Markdown
import Routes
import Svg.Styled as Svg
import Svg.Styled.Attributes as SvgAttributes


type alias Checkbox =
    { name : String
    , label : String
    }


checkbox : Checkbox -> Bool -> Html Bool
checkbox config value =
    Html.styled Html.label
        [ Css.position Css.relative
        , Css.cursor Css.pointer
        ]
        []
        [ Html.styled Html.input
            [ Css.visibility Css.hidden
            , Css.position Css.absolute
            ]
            [ Attributes.type_ "checkbox"
            , Attributes.checked value
            , Attributes.name config.name
            , Events.onCheck identity
            ]
            []
        , Html.styled Html.div
            [ Css.displayFlex
            ]
            []
            [ Html.styled Html.div
                [ Css.borderRadius <| Css.px 5
                , Css.marginRight <| Css.px 15
                , Css.width <| Css.px 20
                , Css.height <| Css.px 20
                , Css.lineHeight <| Css.px 20
                , Css.textAlign <| Css.center
                , Css.fontSize <| Css.px 14
                , Css.color <| Css.hex "FFF"
                , Css.fontFamily Css.cursive
                , Css.property "user-select" "none"
                , if value then
                    Css.batch
                        [ Css.backgroundColor primaryColor ]

                  else
                    Css.batch
                        [ Css.border3 (Css.px 1) Css.solid (Css.hex "444444") ]
                ]
                []
                [ if value then
                    Html.text "✓"

                  else
                    Html.text ""
                ]
            , Html.styled Html.div
                [ sansSerifFont
                , Css.fontSize <| Css.px 18
                , Css.lineHeight <| Css.px 20
                ]
                []
                [ Html.text config.label ]
            ]
        ]


bodyCopyStyle : Css.Style
bodyCopyStyle =
    Css.batch
        [ Css.fontSize <| Css.px 18
        , Css.lineHeight <| Css.px 30
        , sansSerifFont
        ]


buttonStyle : Css.Style
buttonStyle =
    Css.batch
        [ Css.color primaryColor
        , Css.fontSize <| Css.px 18
        , Css.display Css.inlineBlock
        , Css.height <| Css.px 40
        , Css.lineHeight <| Css.px 40
        , Css.minWidth <| Css.px 250
        , Css.borderRadius <| Css.px 20
        , Css.border3 (Css.px 1) Css.solid primaryColor
        , Css.textAlign Css.center
        , Css.backgroundColor <| Css.hex "FFF"
        , Css.marginRight <| Css.px 25
        , Css.hover [ Css.textDecoration Css.none ]
        , Css.lastChild [ Css.marginRight Css.zero ]
        , Css.cursor Css.pointer
        ]


linkStyle : Css.Style
linkStyle =
    Css.batch
        [ Css.textDecoration Css.none
        , Css.color primaryColor
        , Css.hover [ Css.textDecoration Css.underline ]
        , Global.withClass "button" [ buttonStyle ]
        ]


markdown : String -> Html msg
markdown raw =
    Html.styled Html.div
        [ bodyCopyStyle
        , Global.descendants
            [ Global.each [ Global.h1, Global.h2 ]
                [ Css.margin Css.zero
                , serifFont
                , Css.fontWeight <| Css.int 500
                , Css.color primaryColor
                ]
            , Global.h1
                [ Css.fontSize <| Css.px 72
                , Css.lineHeight <| Css.px 90
                , Css.marginTop <| Css.px 50
                , Css.marginBottom <| Css.px 25
                , Global.adjacentSiblings
                    [ Global.p
                        [ Css.lineHeight <| Css.px 40
                        , Css.fontSize <| Css.px 24
                        , Css.letterSpacing <| Css.px -0.8
                        , Css.color <| Css.hex "444444"
                        ]
                    ]
                ]
            , Global.h2
                [ Css.fontSize <| Css.px 36
                , Css.lineHeight <| Css.px 50
                , Css.marginTop <| Css.px 90
                , Css.marginBottom <| Css.px 10
                ]
            , Global.p
                [ Css.margin Css.zero
                , Css.marginBottom <| Css.px 30
                ]
            , Global.ul
                [ Css.paddingLeft <| Css.em 1
                , Css.marginBottom <| Css.px 30
                ]
            , Global.a [ linkStyle ]
            ]
        ]
        []
        [ raw
            |> Markdown.toHtmlWith
                { githubFlavored = Nothing
                , defaultHighlighting = Nothing
                , sanitize = False
                , smartypants = False
                }
                []
            |> Html.fromUnstyled
        ]


page : Html msg -> Html msg
page content =
    Html.styled Html.div
        [ Css.padding <| Css.px 100
        , Css.paddingBottom Css.zero
        , Css.backgroundImage <| Css.url "/static/images/waves.svg"
        , Css.minHeight <| Css.pct 100
        , Css.backgroundRepeat Css.noRepeat
        , Css.backgroundSize Css.contain
        , Css.borderTop3 (Css.px 5) Css.solid primaryColor
        , Css.property "display" "grid"
        , Css.property "grid-template-columns" "200px minmax(auto, 650px)"
        , Css.property "grid-column-gap" "48px"
        , Css.property "grid-template-rows" "1fr 100px"
        , Css.justifyContent Css.center
        ]
        []
        [ Html.styled Html.img
            [ Css.width <| Css.px 200
            , Css.height <| Css.px 200
            , Css.property "grid-row" "1"
            , Css.property "grid-column" "1"
            ]
            [ Attributes.src "/static/images/elm-logo.svg" ]
            []
        , Html.styled Html.div
            [ Css.property "grid-row" "1"
            , Css.property "grid-column" "2"
            ]
            []
            [ content ]
        , Html.styled Html.nav
            [ -- appearance
              Css.width (Css.pct 100)
            , Css.borderTop3 (Css.px 3) Css.solid primaryColor
            , Css.backgroundColor (Css.hex "FFFFFF")

            -- position
            , Css.position Css.fixed
            , Css.left Css.zero
            , Css.bottom Css.zero

            -- contents
            , Css.displayFlex
            , Css.justifyContent Css.center
            , Css.alignItems Css.center
            , sansSerifFont
            ]
            []
            [ footerLink Routes.Index "Home"
            , footerLink Routes.SpeakAtElmConf "Speak"
            ]
        ]


footerLink : Routes.Route -> String -> Html msg
footerLink route title =
    Html.styled Html.a
        [ Css.fontSize <| Css.px 18
        , Css.color <| primaryColor
        , Css.textDecoration Css.none
        , Css.hover [ Css.textDecoration Css.underline ]
        , Css.padding2 (Css.px 10) (Css.px 15)
        ]
        [ Attributes.href <| Routes.path route [] ]
        [ Html.text title ]


primaryColor : Css.Color
primaryColor =
    Css.hex "FF5F6D"


errorColor : Css.Color
errorColor =
    Css.hex "D81B60"


serifFont : Css.Style
serifFont =
    Css.fontFamilies [ "Vollkorn" ]


sansSerifFont : Css.Style
sansSerifFont =
    Css.fontFamilies [ "Work Sans" ]
