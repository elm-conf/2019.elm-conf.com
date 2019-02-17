module Document.Heading exposing (Level, demote, levelBlock, viewAtLevel)

import Html exposing (Attribute, Html)
import Mark exposing (Block)


type Level
    = First
    | Second
    | Third
    | Fourth
    | Fifth
    | Sixth


demote : Level -> Level
demote level =
    case level of
        First ->
            Second

        Second ->
            Third

        Third ->
            Fourth

        Fourth ->
            Fifth

        Fifth ->
            Sixth

        Sixth ->
            Sixth


viewAtLevel : Level -> List (Attribute msg) -> List (Html msg) -> Html msg
viewAtLevel level =
    case level of
        First ->
            Html.h1

        Second ->
            Html.h2

        Third ->
            Html.h3

        Fourth ->
            Html.h4

        Fifth ->
            Html.h5

        Sixth ->
            Html.h6


levelBlock : Block Level
levelBlock =
    -- Yes, I know there are more levels than this, but for this particular
    -- case I want us never to explicitly use them!
    Mark.oneOf
        [ Mark.exactly "first" First
        , Mark.exactly "second" Second
        , Mark.exactly "third" Third
        , Mark.exactly "fourth" Fourth
        ]
