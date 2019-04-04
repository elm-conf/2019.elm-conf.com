module Page.Register exposing (Model, Msg, empty, update, view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Html.Styled.Lazy as Lazy
import String.Verify
import Ui
import Ui.TextInput as TextInput exposing (TextInput, textInput)
import Verify


type alias Model =
    { inputs : Inputs
    , errors : List String
    }


type alias Inputs =
    { name : String
    , email : String
    , password : String
    }


type Msg
    = UpdateName String
    | UpdateEmail String
    | UpdatePassword String
    | Register


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ inputs } as model) =
    case msg of
        UpdateName name ->
            ( { model | inputs = { inputs | name = name } }, Cmd.none )

        UpdateEmail email ->
            ( { model | inputs = { inputs | email = email } }, Cmd.none )

        UpdatePassword password ->
            ( { model | inputs = { inputs | password = password } }, Cmd.none )

        Register ->
            case validator model.inputs of
                Ok valid ->
                    -- TODO: make registration request to graphql
                    ( { model | inputs = valid, errors = [] }
                    , Cmd.none
                    )

                Err ( first, rest ) ->
                    ( { model | errors = first :: rest }
                    , Cmd.none
                    )


empty =
    { inputs =
        { name = ""
        , email = ""
        , password = ""
        }
    , errors = []
    }


validator : Verify.Validator String Inputs Inputs
validator =
    Verify.validate Inputs
        |> Verify.verify .name (String.Verify.notBlank "Please enter your name. We need it to get in touch with you if your talk is selected.")
        |> Verify.verify .email (String.Verify.notBlank "Please enter your email address. We need it to get in touch with you for talk feedback and acceptance notifications.")
        |> Verify.verify .password (String.Verify.notBlank "Please set a password.")


view : Model -> String -> Html Msg
view model topContent =
    Html.main_ []
        [ Ui.markdown topContent
        , case model.errors of
            [] ->
                Html.text ""

            errors ->
                errors
                    |> List.map
                        (\error ->
                            Html.styled Html.li
                                [ Ui.bodyCopyStyle
                                , Css.marginBottom (Css.px 5)
                                ]
                                []
                                [ Html.text error ]
                        )
                    |> Html.ul []
        , Html.form
            [ Events.onSubmit Register ]
            [ styledTextInput "name"
                |> TextInput.withLabel "Your Name"
                |> TextInput.withPlaceholder "Cool Speaker Person"
                |> TextInput.withValue model.inputs.name
                |> TextInput.onInput UpdateName
                |> TextInput.view
            , styledTextInput "email"
                |> TextInput.withLabel "Your Email Address"
                |> TextInput.withPlaceholder "you@awesomeperson.com"
                |> TextInput.withType TextInput.Email
                |> TextInput.withValue model.inputs.email
                |> TextInput.onInput UpdateEmail
                |> TextInput.view
            , styledTextInput "password"
                |> TextInput.withLabel "Your Password"
                |> TextInput.withType TextInput.Password
                |> TextInput.withValue model.inputs.password
                |> TextInput.onInput UpdatePassword
                |> TextInput.view
            , Html.input
                [ Attributes.type_ "submit" ]
                [ Html.text "Register" ]
            ]
        ]


styledTextInput : String -> TextInput String
styledTextInput =
    textInput
        >> TextInput.withStyle [ Css.margin2 (Css.px 30) Css.zero ]
