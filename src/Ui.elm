module Ui exposing (Page, page)

import Css
import Html.Styled as Html exposing (Html)
import Svg.Styled as Svg
import Svg.Styled.Attributes as SvgAttributes


type alias Page =
    { title : String
    }


page : Page -> Html msg
page data =
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
        [ elmLogo
        , Html.styled Html.div
            [ Css.paddingTop <| Css.px 50 ]
            []
            [ Html.styled Html.h1
                [ Css.color primaryColor
                , Css.fontFamilies [ "Vollkorn" ]
                , Css.fontSize <| Css.px 72
                , Css.margin Css.zero
                , Css.lineHeight <| Css.px 91
                ]
                []
                [ Html.text data.title ]
            ]
        ]


elmLogo : Html msg
elmLogo =
    Svg.styled Svg.svg
        [ Css.fill primaryColor
        , Css.width <| Css.px 200
        , Css.height <| Css.px 200
        ]
        [ SvgAttributes.viewBox "0 0 324 324"
        ]
        [ Svg.g
            [ SvgAttributes.fillRule "nonzero" ]
            [ Svg.polygon [ SvgAttributes.points "162.000501 153 232 83 92 83" ] []
            , Svg.polygon [ SvgAttributes.points "9 0 79.264979 70 232 70 161.734023 0" ] []
            , Svg.polygon
                [ SvgAttributes.transform "translate(247.311293, 161.311293) rotate(45.000000) translate(-247.311293, -161.311293)"
                , SvgAttributes.points "193.473809 107.228311 301.473809 107.228311 301.473809 215.228311 193.473809 215.228311"
                ]
                []
            , Svg.polygon [ SvgAttributes.points "324 144 324 0 180 0" ] []
            , Svg.polygon [ SvgAttributes.points "153 161.998999 0 9 0 315" ] []
            , Svg.polygon [ SvgAttributes.points "256 246.999498 324 315 324 179" ] []
            , Svg.polygon [ SvgAttributes.points "161.999499 171 9 324 315 324" ] []
            ]
        ]


primaryColor : Css.Color
primaryColor =
    Css.hex "FF5F6D"
