module Page.Index exposing (view)

import Css
import Html.Styled as Html exposing (Html)
import Ui


view : Html msg
view =
    Ui.page
        { title = "elm-conf"
        }
