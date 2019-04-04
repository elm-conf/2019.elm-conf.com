module Page.Register exposing (Model, Msg, empty, update, view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Lazy as Lazy
import String.Verify
import Ui
import Ui.TextInput as TextInput exposing (TextInput, textInput)
import Verify


type alias Model =
    { name : String
    , email : String
    , password : String
    }


type Msg
    = UpdateName String
    | UpdateEmail String
    | UpdatePassword String


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
        [ Ui.markdown topContent
        , Html.form
            []
            [ styledTextInput "name"
                |> TextInput.withLabel "Your Name"
                |> TextInput.withPlaceholder "Cool Speaker Person"
                |> TextInput.withValue model.name
                |> TextInput.onInput UpdateName
                |> TextInput.view
            , styledTextInput "email"
                |> TextInput.withLabel "Your Email Address"
                |> TextInput.withPlaceholder "you@awesomeperson.com"
                |> TextInput.withType TextInput.Email
                |> TextInput.withValue model.email
                |> TextInput.onInput UpdateEmail
                |> TextInput.view
            , styledTextInput "password"
                |> TextInput.withLabel "Your Password"
                |> TextInput.withType TextInput.Password
                |> TextInput.withValue model.password
                |> TextInput.onInput UpdatePassword
                |> TextInput.view
            ]
        ]


styledTextInput : String -> TextInput String
styledTextInput =
    textInput
        >> TextInput.withStyle [ Css.margin2 (Css.px 30) Css.zero ]
