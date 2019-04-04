module Ui.Button exposing
    ( Button, button, view
    , withLabel, onClick
    )

{-|

@docs Button, button, view

@docs withLabel, onClick

-}

import Css exposing (Style)
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Html.Styled.Lazy as Lazy
import Regex
import Ui


type Button msg
    = Button
        { label : String
        , onClick : msg
        }


button : Button ()
button =
    Button
        { label = ""
        , onClick = ()
        }


withLabel : String -> Button msg -> Button msg
withLabel label (Button config) =
    Button { config | label = label }


onClick : msgB -> Button msgA -> Button msgB
onClick onClick_ (Button config) =
    Button
        { label = config.label

        -- the new one, of a new type...
        , onClick = onClick_
        }


view : Button msg -> Html msg
view (Button config) =
    Html.styled Html.button
        [ Ui.buttonStyle ]
        [ Events.onClick config.onClick ]
        [ Html.text config.label ]
