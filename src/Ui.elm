module Ui exposing
    ( Checkbox
    , bodyCopyStyle
    , buttonStyle
    , checkbox
    , desktopOnly
    , errorColor
    , linkStyle
    , markdown
    , page
    , primaryColor
    , responsive
    , sansSerifFont
    , serifFont
    )

import Css exposing (Style)
import Css.Global as Global
import Css.Media exposing (maxWidth, minWidth, only, screen, withMedia)
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
        [ Css.color primaryHighContrastColor
        , Css.fontSize <| Css.px 18
        , Css.display Css.inlineBlock
        , Css.height <| Css.px 40
        , Css.lineHeight <| Css.px 40
        , Css.minWidth <| Css.px 250
        , Css.borderRadius <| Css.px 20
        , Css.border3 (Css.px 1) Css.solid primaryHighContrastColor
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
        , Css.color primaryHighContrastColor
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


mainContentId : String
mainContentId =
    "main"


page : { setFocus : String -> msg, photo : Maybe String, content : Html msg } -> Html msg
page { setFocus, photo, content } =
    Html.styled Html.div
        [ Css.paddingBottom Css.zero
        , Css.backgroundImage <| Css.url "/images/waves.svg"
        , Css.minHeight <| Css.pct 100
        , Css.backgroundRepeat Css.noRepeat
        , Css.backgroundSize Css.contain
        , Css.borderTop3 (Css.px 5) Css.solid primaryColor
        , Css.justifyContent Css.center
        , Css.property "display" "grid"
        , responsive
            { desktop =
                [ Css.padding <| Css.px 100
                , Css.property "grid-template-columns" "200px minmax(auto, 650px)"
                , Css.property "grid-template-rows" "50px 1fr 100px"
                , Css.property "grid-column-gap" "48px"
                ]
            , mobile =
                [ Css.padding <| Css.px 50
                , Css.property "grid-template-columns" "1fr"
                ]
            }
        ]
        []
        [ skipToContent (setFocus mainContentId)
        , navigation
        , header photo
        , Html.styled Html.main_
            [ desktopOnly
                [ Css.property "grid-row" "2"
                , Css.property "grid-column" "2"
                ]
            , Css.marginBottom (Css.px 50)

            -- we remote the outline of this div. It's not a input element, but
            -- we need to be able to change the focus so that we can properly
            -- skip to content for keyboard and screen reader nav.
            , Css.focus [ Css.outline Css.none ]
            ]
            [ Attributes.id mainContentId
            , Attributes.tabindex -1
            ]
            [ content ]
        , footer
        ]


skipToContent : msg -> Html msg
skipToContent focusOnContent =
    Html.styled Html.a
        [ Css.position Css.absolute
        , Css.color primaryHighContrastColor
        , Css.textDecoration Css.none

        -- hidden by default
        , Css.left (Css.px -1000)
        , Css.top (Css.px -1000)
        , Css.height (Css.px 1)
        , Css.width (Css.px 1)
        , Css.overflow Css.hidden

        -- shown when the link is active, focused, and hovering
        , [ Css.focus, Css.active, Css.hover ]
            |> List.map
                (\pseudoSelector ->
                    pseudoSelector
                        [ Css.left Css.zero
                        , Css.top (Css.px 5)
                        , Css.width Css.auto
                        , Css.height Css.auto
                        , Css.overflow Css.visible
                        , Css.padding (Css.px 25)
                        ]
                )
            |> Css.batch
        ]
        [ Attributes.href ("#" ++ mainContentId)
        , Events.onClick focusOnContent
        ]
        [ Html.text "Skip to content" ]


header : Maybe String -> Html msg
header photo =
    Html.styled Html.header
        [ desktopOnly
            [ Css.property "grid-row" "1 / 2"
            , Css.property "grid-column" "1"
            ]
        ]
        []
        [ Html.styled Html.img
            [ Css.width <| Css.px 200
            , case photo of
                Nothing ->
                    Css.height (Css.px 200)

                Just _ ->
                    Css.batch
                        [ Css.height (Css.px 242)
                        , Css.borderRadius (Css.px 30)
                        , responsive
                            { desktop = [ Css.marginTop (Css.px -21) ]
                            , mobile = [ Css.margin2 Css.zero Css.auto ]
                            }
                        ]
            ]
            [ photo
                |> Maybe.withDefault "/images/elm-logo.svg"
                |> Attributes.src
            , Attributes.alt ""
            ]
            []
        ]


navigation : Html msg
navigation =
    Html.styled Html.nav
        [ Css.displayFlex
        , Css.justifyContent Css.flexStart
        , Css.alignItems Css.center
        , sansSerifFont
        , desktopOnly
            [ Css.property "grid-row" "1"
            , Css.property "grid-column" "2"

            -- compensate for the first link target having a left margin
            , Css.marginLeft (Css.px -10)
            ]
        ]
        []
        [ navLink "Home" <| Routes.path Routes.Index []
        , navLink "Speak" <| Routes.path Routes.SpeakAtElmConf []
        , navLink "Twitter" "https://twitter.com/elmconf"
        , navLink "Instagram" "https://instagram.com/elmconf"
        ]


navLink : String -> String -> Html msg
navLink title url =
    Html.styled Html.a
        [ Css.fontSize <| Css.px 18
        , Css.color primaryHighContrastColor
        , Css.textDecoration Css.none
        , Css.hover [ Css.textDecoration Css.underline ]
        , Css.padding2 (Css.px 10) (Css.px 15)
        ]
        [ Attributes.href url ]
        [ Html.text title ]


footer : Html msg
footer =
    Html.styled Html.footer
        [ desktopOnly
            [ Css.property "grid-row" "3"
            , Css.property "grid-column" "2"
            , Css.property "display" "grid"
            , Css.property "grid-template-columns" "2fr 2fr 1fr"
            , Css.property "grid-column-gap" "10px"
            ]
        ]
        []
        [ markdown "### Code of Conduct\n\nParticipation in elm-conf is governed by the [Strange Loop Code of Conduct](https://thestrangeloop.com/policies.html)."
        , markdown "### Sponsorships\n\nelm-conf sponsorships are available at a variety of levels. Please [email elm-conf@thestrangeloop.com](mailto:elm-conf@thestrangeloop.com) for more information."
        , markdown "### Contact\n\n- [Email](mailto:elm-conf@thestrangeloop.com)\n- [Twitter](https://twitter.com/elmconf)\n- [Instagram](https://instagram.com/elmconf)"
        ]


footerSection : Html msg -> List (Html msg) -> Html msg
footerSection title body =
    Html.styled Html.p
        []
        []
        (Html.h3 [] [ title ] :: body)


primaryColor : Css.Color
primaryColor =
    Css.hex "FF5F6D"


primaryHighContrastColor : Css.Color
primaryHighContrastColor =
    Css.hex "EE0015"


errorColor : Css.Color
errorColor =
    Css.hex "D81B60"


serifFont : Css.Style
serifFont =
    Css.fontFamilies [ "Vollkorn" ]


sansSerifFont : Css.Style
sansSerifFont =
    Css.fontFamilies [ "Work Sans" ]


responsive : { desktop : List Style, mobile : List Style } -> Style
responsive { desktop, mobile } =
    Css.batch
        [ withMedia [ only screen [ minWidth (Css.px 801) ] ] desktop
        , withMedia [ only screen [ maxWidth (Css.px 800) ] ] mobile
        ]


desktopOnly : List Style -> Style
desktopOnly styles =
    responsive
        { desktop = styles
        , mobile = []
        }
