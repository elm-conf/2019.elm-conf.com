module Page.Schedule exposing (view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Time exposing (Posix)
import Ui


type Event
    = Talk
        { speakerName : String
        , speakerPhoto : String
        , speakerBio : String
        , moreText : String
        , moreLink : String
        }
    | Break
        { description : String
        , additionalInfo : Maybe String
        }


stLouis : Time.Zone
stLouis =
    -- with respect to DST the day of the event
    Time.customZone (-5 * 60) []


events : List ( Posix, Event )
events =
    [ ( Time.millisToPosix 1568293200000
      , Break
            { description = "Doors and registration open."
            , additionalInfo = Just "test test test badges on first floor outside doors etc"
            }
      )
    , ( Time.millisToPosix 1568296800000
      , Talk
            { speakerName = "Tessa Kelly"
            , speakerPhoto = "/images/speakers/tessa-kelly.png"
            , speakerBio = "Tessa helps teachers teach grammar and writing as an engineer at NoRedInk. She's excited about accessibility, colors, and testing. Ask her about New Mexico if you are interested in being talked at."
            , moreText = "Tessa's Talk: *Writing Testable Elm*"
            , moreLink = "/speakers/tessa-kelly"
            }
      )
    , ( Time.millisToPosix 1568298600000
      , Break
            { description = "Short Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568298900000
      , Talk
            { speakerName = "Abadi Kurniawan"
            , speakerPhoto = "/images/speakers/abadi-kurniawan.jpg"
            , speakerBio = "Abadi is a full stack engineer at 1904labs, where he spends most of his innovation hours hacking on Elm and Rust. In his free time, he enjoys learning new programming languages, playing video games, and watching movies with his wife and son."
            , moreText = "Abadi's Talk: *Building highly performant animations in Elm.*"
            , moreLink = "/speakers/abadi-kurniawan"
            }
      )
    , ( Time.millisToPosix 1568300700000
      , Break
            { description = "Short Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568301000000
      , Talk
            { speakerName = "Brooke Angel"
            , speakerPhoto = "/images/speakers/brooke-angel.jpg"
            , speakerBio = "Brooke is a software engineer at NoRedInk, where she builds educational software in Elm. When she isn't testing Elm code, you can find her testing out new salsa moves on the dance floor."
            , moreText = "Brooke's Talk: *A Month of Accessible Elm*"
            , moreLink = "/speakers/brooke-angel"
            }
      )
    , ( Time.millisToPosix 1568302800000
      , Break
            { description = "Long Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568304600000
      , Talk
            { speakerName = "James Carlson"
            , speakerPhoto = "/images/speakers/james-carlson.jpg"
            , speakerBio = "James Carlson worked for many years as a math professor.  Since he retired an undisclosed number of years ago, he has been dabbling in functional programing, mostly Elm, but also (lately) some Futhark, a functional language that compiles to optimized GPU code.  He is trying to learn type theory, which combines philosophy, logic, mathematics, and functional programming.  What more could one ask for?  His main contributions to Elm are the jxxcarlson/elm-tar and minilatex packages. The function of the latter is to parse a subset of LaTeX and render it to HTML."
            , moreText = "James' Talk: *Making Elm talk to your personal Supercomputer*"
            , moreLink = "/speakers/james-carlson"
            }
      )
    , ( Time.millisToPosix 1568306400000
      , Break
            { description = "Short Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568306700000
      , Talk
            { speakerName = "Ryan Frazier"
            , speakerPhoto = "/images/speakers/ryan-frazier.jpg"
            , speakerBio = "Before switching careers to programming web applications, Ryan Frazier was an aspiring concert pianist. Recently, he discovered the power of Elm and SVG to do music stuff in the browser."
            , moreText = "Ryan's Talk: *Building a Music Theory API with Types*"
            , moreLink = "/speakers/ryan-frazier"
            }
      )
    , ( Time.millisToPosix 1568308500000
      , Break
            { description = "Lunch"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568313900000
      , Break
            { description = "elm-conf resumes after lunch"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568314200000
      , Talk
            { speakerName = "Liz Krane"
            , speakerPhoto = "/images/speakers/liz-krane.jpg"
            , speakerBio = "Liz Krane is a developer advocate at Sentry and founder of Learn Teach Code, an organization that empowers aspiring developers to lead their own local events to create stronger, more diverse tech communities. She loves finding new ways to combine code with other disciplines like art and music, sharing everything she learns while she tries to learn everything!"
            , moreText = "Liz's Talk: *Building a Music Learning Game with Elm, Web MIDI, and SVG Animation*"
            , moreLink = "/speakers/liz-krane"
            }
      )
    , ( Time.millisToPosix 1568316000000
      , Break
            { description = "Short Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568316300000
      , Talk
            { speakerName = "James Gary"
            , speakerPhoto = "/images/speakers/james-gary.jpg"
            , speakerBio = "James has worked as a web developer at companies like NoRedInk and SendGrid, and is currently pursing game development full time."
            , moreText = "James' Talk: *Game Development in Elm: Build your own tooling*"
            , moreLink = "/speakers/james-gary"
            }
      )
    , ( Time.millisToPosix 1568318100000
      , Break
            { description = "Long Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568319900000
      , Talk
            { speakerName = "Katie Hughes"
            , speakerPhoto = "/images/speakers/katie-hughes.jpeg"
            , speakerBio = "Katie Hughes is your friendly neighborhood software engineer who works at NoRedInk. She relates to both Dick Grayson and Selina Kyle since she attends circus school and adores her black cat."
            , moreText = "Katie's Talk: *GraphQSquirrel*"
            , moreLink = "/speakers/katie-hughes"
            }
      )
    , ( Time.millisToPosix 1568321700000
      , Break
            { description = "Short Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568322000000
      , Talk
            { speakerName = "Ian Mackenzie"
            , speakerPhoto = "/images/speakers/ian-mackenzie.jpeg"
            , speakerBio = "Ian is the author of the elm-geometry and elm-units packages and is passionate about using Elm as a platform for design, engineering and manufacturing."
            , moreText = "Ian's Talk: *A 3D Rendering Engine for Elm*"
            , moreLink = "/speakers/ian-mackenzie"
            }
      )
    , ( Time.millisToPosix 1568323800000
      , Break
            { description = "Short Break"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568324100000
      , Talk
            { speakerName = "Katja Mordaunt"
            , speakerPhoto = "/images/speakers/katja-mordaunt.jpg"
            , speakerBio = "Katja is a developer with neontribe.co.uk where she mostly makes web apps that aim to improve the reach of small charities. She works iteratively with clients and users to get as close as possible to what people need. Her choice of tools (apart from vim and linux) depends on the project, but she often writes APIs in php and frontends in React (when she has to) and Elm (when she can). She values community, open source, transparency, itegrity, generally sharing stuff and giving everyone a voice. She hopes every day to contribute towards sucking a little bit of despair out of the world and adding a lot of empowerment. In a past life she produced independent films and is a believer that sharing stories makes the world a better place."
            , moreText = "Katja's Talk: *Growing an Elm project with the whole team*"
            , moreLink = "/speakers/katja-mordaunt"
            }
      )
    , ( Time.millisToPosix 1568325900000
      , Break
            { description = "Closing Ceremonies"
            , additionalInfo = Nothing
            }
      )
    , ( Time.millisToPosix 1568332800000
      , Break
            { description = "Strange Loop Party"
            , additionalInfo = Nothing
            }
      )

    -- , ( "4:35 PM", "Katja Mordaunt" )
    -- , ( "5:05 PM", "Closing Ceremonies" )
    -- , ( "7:00 PM", "Strange Loop Party" )
    -- , ( "9:35 AM", "Abadi Kurniawan" )
    -- , ( "10:05 AM", "Short Break" )
    -- , ( "10:10 AM", "Brooke Angel" )
    -- , ( "10:40 AM", "Long Break" )
    -- , ( "11:10 AM", "Jim Carlson" )
    -- , ( "11:40 AM", "Short Break" )
    -- , ( "11:45 AM", "Ryan Frazier" )
    -- , ( "12:15 PM", "Lunch" )
    -- , ( "1:45 PM", "elm-conf resumes after lunch" )
    -- , ( "1:50 PM", "Liz Krane" )
    -- , ( "2:20 PM", "Short Break" )
    -- , ( "2:25 PM", "James Gary" )
    -- , ( "2:55 PM", "Long Break" )
    -- , ( "3:25 PM", "Katie Hughes" )
    -- , ( "3:55 PM", "Short Break" )
    -- , ( "4:00 PM", "Ian Mackenzie" )
    -- , ( "4:30 PM", "Short Break" )
    ]


view : String -> Html msg
view topContent =
    Html.div []
        [ Ui.markdown False topContent
        , events
            |> List.map viewEvent
            |> Html.div []
        ]


viewEvent : ( Posix, Event ) -> Html msg
viewEvent ( startTime, event ) =
    Html.styled Html.div
        [ Ui.desktopOnly
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "158px minmax(auto, 650px)"
            , Css.marginLeft <| Css.px -158
            , Css.minHeight <| Css.px 120
            ]
        ]
        []
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
                    , case event of
                        Break _ ->
                            Css.border3 (Css.px 5) Css.solid (Css.hex "D8D8D8")

                        Talk _ ->
                            Css.border3 (Css.px 5) Css.solid Ui.primaryColor
                    , Css.backgroundColor <| Css.hex "FFF"
                    , Css.width <| Css.px 20
                    , Css.height <| Css.px 20
                    , Css.marginRight <| Css.px 4
                    ]
                    []
                    []
                , viewTime startTime
                ]
            , Html.styled Html.div
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
            ]
        , Html.styled Html.div
            []
            []
            (viewDescription event)
        ]


viewDescription : Event -> List (Html msg)
viewDescription event =
    case event of
        Talk { speakerName, speakerBio, moreText, moreLink } ->
            [ Ui.markdown True
                ("## "
                    ++ speakerName
                    ++ "\n\n"
                    ++ speakerBio
                    ++ "\n\n["
                    ++ moreText
                    ++ " »]("
                    ++ moreLink
                    ++ ")"
                )
            ]

        Break { description, additionalInfo } ->
            [ Ui.markdown False
                (description
                    ++ (additionalInfo
                            |> Maybe.map ((++) "\n\n")
                            |> Maybe.withDefault ""
                       )
                )
            ]


viewTime : Posix -> Html msg
viewTime time =
    let
        hour24 =
            Time.toHour stLouis time

        minute =
            Time.toMinute stLouis time

        ( hour12, period ) =
            if hour24 == 12 then
                ( hour24, "pm" )

            else if hour24 > 12 then
                ( hour24 - 12, "pm" )

            else
                ( hour24, "am" )
    in
    Html.styled Html.div
        [ Ui.sansSerifFont
        , Css.fontSize <| Css.px 18
        , Css.color <| Css.hex "444444"
        , Css.letterSpacing <| Css.px -0.6
        ]
        []
        [ hour12 |> String.fromInt |> Html.text
        , Html.text ":"
        , minute |> String.fromInt |> String.padLeft 2 '0' |> Html.text
        , Html.text " "
        , Html.text period
        ]
