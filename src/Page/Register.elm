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
            [ viewNameInput model.name |> Html.map UpdateName
            , viewEmailInput model.email |> Html.map UpdateEmail
            , viewPasswordInput model.password |> Html.map UpdatePassword
            ]
        ]


{-| TODO: should be shared with Cfp.elm
-}
viewNameInput : String -> Html String
viewNameInput =
    Lazy.lazy <|
        Ui.textInput
            { name = "name"
            , label = Just "Your Name"
            , placeholder = "Cool Speaker Person"
            , type_ = "text"
            }


{-| TODO: should be shared with Cfp.elm
-}
viewEmailInput : String -> Html String
viewEmailInput =
    Lazy.lazy <|
        Ui.textInput
            { name = "email"
            , label = Just "Your Email Address"
            , placeholder = "you@awesomeperson.com"
            , type_ = "email"
            }


{-| TODO: should be shared with Cfp.elm
-}
viewPasswordInput : String -> Html String
viewPasswordInput =
    Lazy.lazy <|
        Ui.textInput
            { name = "password"
            , label = Just "Your Password"
            , placeholder = ""
            , type_ = "password"
            }
