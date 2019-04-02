module Ui exposing (Markdown(..), page)

import Css
import Css.Global as Global
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Markdown
import Svg.Styled as Svg
import Svg.Styled.Attributes as SvgAttributes


type Markdown
    = Markdown String


page : Markdown -> Html msg
page (Markdown markdown) =
    Html.styled Html.div
        [ Css.padding <| Css.px 100
        , Css.backgroundImage <| Css.url "/static/images/waves.svg"
        , Css.minHeight <| Css.pct 100
        , Css.backgroundRepeat Css.noRepeat
        , Css.backgroundSize Css.contain
        , Css.borderTop3 (Css.px 5) Css.solid primaryColor
        , Css.property "display" "grid"
        , Css.property "grid-template-columns" "200px auto"
        , Css.property "grid-column-gap" "48px"
        ]
        []
        [ Html.styled Html.img
            [ Css.width <| Css.px 200
            , Css.height <| Css.px 200
            ]
            [ Attributes.src "/static/images/elm-logo.svg" ]
            []
        , Html.styled Html.div
            [ Css.fontSize <| Css.px 18
            , Css.lineHeight <| Css.px 30
            , sansSerifFont
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
                    , Css.paddingTop <| Css.px 50
                    , Css.paddingBottom <| Css.px 25
                    , Global.adjacentSiblings
                        [ Global.p
                            [ Css.lineHeight <| Css.px 40
                            , Css.fontSize <| Css.px 24
                            , Css.letterSpacing <| Css.px -0.8
                            , Css.color <| Css.hex "444444"
                            , Css.marginBottom Css.zero
                            ]
                        ]
                    ]
                , Global.h2
                    [ Css.fontSize <| Css.px 36
                    , Css.lineHeight <| Css.px 50
                    , Css.paddingTop <| Css.px 90
                    , Css.paddingBottom <| Css.px 10
                    ]
                , Global.p
                    [ Css.margin Css.zero
                    , Css.marginBottom <| Css.px 30
                    ]
                , Global.ul
                    [ Css.paddingLeft <| Css.em 1
                    , Css.marginBottom <| Css.px 30
                    ]
                ]
            ]
            []
            [ markdown
                |> String.split "---"
                |> List.drop 1
                |> String.join "---"
                |> Markdown.toHtmlWith
                    { githubFlavored = Nothing
                    , defaultHighlighting = Nothing
                    , sanitize = False
                    , smartypants = False
                    }
                    []
                |> Html.fromUnstyled
            ]
        ]


primaryColor : Css.Color
primaryColor =
    Css.hex "FF5F6D"


serifFont : Css.Style
serifFont =
    Css.fontFamilies [ "Vollkorn" ]


sansSerifFont : Css.Style
sansSerifFont =
    Css.fontFamilies [ "Work Sans" ]
