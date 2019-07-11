module Page.Schedule exposing (view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Ui


events : List ( String, String )
events =
    [ ( "8:00 AM", "Doors and registration open." )
    , ( "9:00 AM", "Tessa Kelly" )
    , ( "9:30 AM", "Short Break" )
    , ( "9:35 AM", "Abadi Kurniawan" )
    , ( "10:05 AM", "Short Break" )
    , ( "10:10 AM", "Brooke Angel" )
    , ( "10:40 AM", "Long Break" )
    , ( "11:10 AM", "Jim Carlson" )
    , ( "11:40 AM", "Short Break" )
    , ( "11:45 AM", "Ryan Frazier" )
    , ( "12:15 PM", "Lunch" )
    , ( "1:45 PM", "elm-conf resumes after lunch" )
    , ( "1:50 PM", "Liz Krane" )
    , ( "2:20 PM", "Short Break" )
    , ( "2:25 PM", "James Gary" )
    , ( "2:55 PM", "Long Break" )
    , ( "3:25 PM", "Katie Hughes" )
    , ( "3:55 PM", "Short Break" )
    , ( "4:00 PM", "Ian Mackenzie" )
    , ( "4:30 PM", "Short Break" )
    , ( "4:35 PM", "Katja Mordaunt" )
    , ( "5:05 PM", "Closing Ceremonies" )
    , ( "7:00 PM", "Strange Loop Party" )
    ]


view : String -> Html msg
view topContent =
    Html.div []
        [ Ui.markdown topContent
        , events
            |> List.map (viewEvent True)
            |> Html.div []
        ]


viewEvent : Bool -> ( String, String ) -> Html msg
viewEvent hasBorder ( startTime, description ) =
    Html.styled Html.div
        [ Ui.desktopOnly
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "158px minmax(auto, 650px)"
            , Css.marginLeft <| Css.px -158
            , Css.minHeight <| Css.px 120
            ]
        ]
        [ Attributes.id <| "section-" ++ description ]
        [ Html.styled Html.div
            [ Ui.desktopOnly
                [ Css.property "display" "grid"
                , Css.property "grid-template-rows" "30px 1fr"
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
                    , Css.border3 (Css.px 5) Css.solid (Css.hex "D8D8D8")
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
                    [ Html.text startTime ]
                ]
            , if hasBorder then
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
        , Html.styled Html.div
            [ Css.displayFlex
            , Css.alignItems Css.center
            , Css.height <| Css.px 30
            ]
            []
            (description
                |> String.split "\n\n"
                |> List.map
                    (Html.text
                        >> List.singleton
                        >> Html.styled Html.p
                            [ Css.margin Css.zero
                            , Css.fontSize <| Css.px 18
                            , Ui.sansSerifFont
                            , Css.lineHeight <| Css.px 30
                            ]
                            []
                    )
            )
        ]
