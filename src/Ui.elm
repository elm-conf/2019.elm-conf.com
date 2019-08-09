module Ui exposing
    ( Checkbox
    , bodyCopyStyle
    , buttonStyle
    , checkbox
    , desktopOnly
    , errorColor
    , image
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


bigHeaderStyle : Css.Style
bigHeaderStyle =
    Css.batch
        [ Css.margin Css.zero
        , serifFont
        , Css.fontWeight <| Css.int 500
        , Css.color primaryColor
        ]


h1Style : Css.Style
h1Style =
    Css.batch
        [ bigHeaderStyle
        , Css.fontSize <| Css.px 72
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


h2Style : Css.Style
h2Style =
    Css.batch
        [ bigHeaderStyle
        , Css.fontSize <| Css.px 36
        , Css.lineHeight <| Css.px 50
        , Css.marginTop <| Css.px 90
        , Css.marginBottom <| Css.px 10
        ]


h3Style : Css.Style
h3Style =
    Css.batch
        [ Css.fontSize <| Css.px 18
        , Css.fontWeight <| Css.int 500
        , sansSerifFont
        ]


pStyle : Css.Style
pStyle =
    Css.batch
        [ Css.margin Css.zero
        , Css.marginBottom <| Css.px 30
        ]


ulStyle : Css.Style
ulStyle =
    Css.batch
        [ Css.paddingLeft <| Css.em 1
        , Css.marginBottom <| Css.px 30
        ]


markdown : String -> Html msg
markdown raw =
    Html.styled Html.div
        [ bodyCopyStyle
        , Global.descendants
            [ Global.h1 [ h1Style ]
            , Global.h2 [ h2Style ]
            , Global.h3 [ h3Style ]
            , Global.p [ pStyle ]
            , Global.ul [ ulStyle ]
            , Global.a [ linkStyle ]
            , Global.div
                [ Global.withClass "sponsor-row"
                    [ Css.property "display" "grid"
                    , responsive
                        { desktop =
                            [ Css.property "grid-template-columns" "33% 66%"
                            , Css.property "grid-column-gap" "12px"
                            ]
                        , mobile =
                            [ Css.property "grid-template-columns" "1fr"
                            , Css.property "grid-row-gap" "12px"
                            ]
                        }
                    , Global.descendants
                        [ Global.img [ Css.width (Css.pct 100) ]
                        ]
                    ]
                ]
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


page : { setFocus : String -> msg, photo : Maybe String, title : String, content : Html msg } -> Html msg
page { setFocus, photo, title, content } =
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
        , header photo title
        , Html.styled Html.main_
            [ responsive
                { desktop =
                    [ Css.property "grid-row" "2"
                    , Css.property "grid-column" "2"
                    ]
                , mobile = [ Css.marginTop (Css.px 25) ]
                }
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


navigation : Html msg
navigation =
    Html.styled Html.nav
        [ Css.displayFlex
        , Css.justifyContent Css.flexStart
        , Css.alignItems Css.center
        , sansSerifFont
        , responsive
            { desktop =
                [ Css.property "grid-row" "1"
                , Css.property "grid-column" "2"

                -- compensate for the first link target having a left margin
                , Css.marginLeft (Css.px -10)
                ]
            , mobile =
                [ Css.flexDirection Css.column
                , Css.marginBottom (Css.px 25)
                ]
            }
        ]
        []
        [ navLink "Home" <| Routes.path Routes.Index []
        , navLink "About" <| Routes.path Routes.About []
        , navLink "Travel and Venue" <| Routes.path Routes.TravelAndVenue []
        , navLink "Schedule" <| Routes.path Routes.Schedule []
        , navLink "Sponsors" <| Routes.path Routes.Sponsors []
        , navLink "Buy Tickets" "https://ti.to/strange-loop/2019/with/6vcn1w2pvic"
        ]


header : Maybe String -> String -> Html msg
header photo title =
    Html.styled Html.header
        [ responsive
            { desktop =
                [ Css.property "grid-row" "1"
                , Css.property "grid-column" "1"
                ]
                    ++ (case photo of
                            Just _ ->
                                [ Css.marginTop <| Css.px -21 ]

                            Nothing ->
                                []
                       )
            , mobile = [ Css.margin2 Css.zero Css.auto ]
            }
        ]
        []
        [ image
            (case photo of
                Just src ->
                    { src = src
                    , altText = "Photo of " ++ title
                    , width = 200
                    , height = 242
                    , rounded = True
                    }

                Nothing ->
                    { src = "/images/elm-logo.svg"
                    , altText = "elm-conf"
                    , width = 200
                    , height = 200
                    , rounded = False
                    }
            )
        ]


type alias ImageConfig =
    { src : String
    , altText : String
    , width : Float
    , height : Float
    , rounded : Bool
    }


image : ImageConfig -> Html msg
image config =
    Html.styled Html.img
        ([ Css.width <| Css.px config.width
         , Css.height <| Css.px config.height
         ]
            ++ (if config.rounded then
                    [ Css.borderRadius (Css.px 30) ]

                else
                    []
               )
        )
        [ Attributes.src config.src
        , Attributes.alt config.altText
        ]
        []


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
        [ Html.section []
            [ Html.styled Html.h2 [ h3Style ] [] [ Html.text "Code of Conduct" ]
            , Html.styled Html.p
                [ bodyCopyStyle ]
                []
                [ Html.text "Participation in elm-conf is governed by the "
                , Html.styled Html.a [ linkStyle ] [ Attributes.href "https://thestrangeloop.com/policies.html" ] [ Html.text "Strange Loop Code of Conduct" ]
                , Html.text "."
                ]
            ]
        , Html.section []
            [ Html.styled Html.h2 [ h3Style ] [] [ Html.text "Sponsorships" ]
            , Html.styled Html.p
                [ bodyCopyStyle ]
                []
                [ Html.text "elm-conf sponsorships are available at a variety of levels. See the "
                , Html.styled Html.a
                    [ linkStyle ]
                    [ Attributes.href "/sponsorship" ]
                    [ Html.text "sponsorship prospectus" ]
                , Html.text " or "
                , Html.styled Html.a
                    [ linkStyle ]
                    [ Attributes.href "mailto:elm-conf@thestrangeloop.com" ]
                    [ Html.text "email elm-conf@thestrangeloop.com" ]
                , Html.text " for more information."
                ]
            ]
        , Html.section []
            [ Html.styled Html.h2 [ h3Style ] [] [ Html.text "Contact" ]
            , Html.styled Html.p
                [ bodyCopyStyle ]
                []
                [ Html.styled Html.ul
                    [ ulStyle ]
                    []
                    [ Html.li []
                        [ Html.styled Html.a
                            [ linkStyle ]
                            [ Attributes.href "mailto:elm-conf@thestrangeloop.com" ]
                            [ Html.text "Email" ]
                        ]
                    , Html.li []
                        [ Html.styled Html.a
                            [ linkStyle ]
                            [ Attributes.href "https://twitter.com/elmconf" ]
                            [ Html.text "Twitter" ]
                        ]
                    , Html.li []
                        [ Html.styled Html.a
                            [ linkStyle ]
                            [ Attributes.href "https://instagram.com/elmconf" ]
                            [ Html.text "Instagram" ]
                        ]
                    ]
                ]
            ]
        ]


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
