module Page.Register exposing (Model, Msg, empty, update, view)

import Html.Styled as Html exposing (Html)
import Html.Styled.Lazy as Lazy
import String.Verify
import Ui
import Verify


type alias Model =
    { name : String
    , email : String
    , password : String
    }


type Msg
    = TODO


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


empty =
    { name = ""
    , email = ""
    , password = ""
    }


validator : Verify.Validator String Model Model
validator =
    Verify.validate Model
        |> Verify.verify .name (String.Verify.notBlank "Please enter your name. We need it to get in touch with you if your talk is selected.")
        |> Verify.verify .email (String.Verify.notBlank "Please enter your email address. We need it to get in touch with you for talk feedback and acceptance notifications.")
        |> Verify.verify .password (String.Verify.notBlank "Please set a password so nobody else can see your talk submissions.")


view : Model -> String -> Html Msg
view model topContent =
    Html.main_ []
        [ Ui.markdown topContent ]
