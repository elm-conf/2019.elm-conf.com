module Page.Register exposing (Model, Msg, ParentMsg(..), empty, update, view)

import Api.InputObject as ApiInputObject
import Api.Mutation as ApiMutation
import Api.Object.AuthenticatePayload as ApiAuthPayload
import Api.Object.RegisterPayload as ApiRegisterPayload
import Api.Scalar as ApiScalar
import Css
import Graphql.Http as Http
import Graphql.SelectionSet as SelectionSet
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events as Events
import Html.Styled.Lazy as Lazy
import String.Verify
import Task
import Ui
import Ui.TextInput as TextInput exposing (TextInput, textInput)
import Verify


type alias Env =
    { graphqlUrl : String }


type alias Model =
    { registerInputs : RegisterInputs
    , formMode : FormMode
    , errors : List String
    }


type alias RegisterInputs =
    { name : String
    , email : String
    , password : String
    }


type Msg
    = UpdateName String
    | UpdateEmail String
    | UpdatePassword String
    | Register
    | RegisterComplete (Maybe String)
    | SwitchFormMode FormMode


type FormMode
    = LoginForm
    | RegisterForm


type ParentMsg
    = Continue
    | Registered String


register : String -> RegisterInputs -> Cmd (Maybe String)
register url inputs =
    SelectionSet.succeed identity
        |> SelectionSet.with ApiRegisterPayload.jwtToken
        |> ApiMutation.register
            { input = ApiInputObject.buildRegisterInput inputs identity }
        |> SelectionSet.map (Maybe.andThen identity)
        |> SelectionSet.map (Maybe.map (\(ApiScalar.JwtToken s) -> s))
        |> Http.mutationRequest url
        |> Http.toTask
        |> Task.onError
            (\_ ->
                SelectionSet.succeed identity
                    |> SelectionSet.with ApiAuthPayload.jwtToken
                    |> ApiMutation.authenticate
                        { input =
                            ApiInputObject.buildAuthenticateInput
                                { email = inputs.email, password = inputs.password }
                                identity
                        }
                    |> SelectionSet.map (Maybe.andThen identity)
                    |> SelectionSet.map (Maybe.map (\(ApiScalar.JwtToken s) -> s))
                    |> Http.mutationRequest url
                    |> Http.toTask
            )
        |> Task.attempt (Result.toMaybe >> Maybe.andThen identity)


update : Env -> Msg -> Model -> ( Model, Cmd Msg, ParentMsg )
update env msg ({ registerInputs } as model) =
    case msg of
        UpdateName name ->
            ( { model | registerInputs = { registerInputs | name = name } }
            , Cmd.none
            , Continue
            )

        UpdateEmail email ->
            ( { model | registerInputs = { registerInputs | email = email } }
            , Cmd.none
            , Continue
            )

        UpdatePassword password ->
            ( { model | registerInputs = { registerInputs | password = password } }
            , Cmd.none
            , Continue
            )

        Register ->
            case registerValidator model.registerInputs of
                Ok valid ->
                    -- TODO: make registration request to graphql
                    ( { model | registerInputs = valid, errors = [] }
                    , register env.graphqlUrl valid
                        |> Cmd.map RegisterComplete
                    , Continue
                    )

                Err ( first, rest ) ->
                    ( { model | errors = first :: rest }
                    , Cmd.none
                    , Continue
                    )

        RegisterComplete (Just token) ->
            ( { model | registerInputs = empty.registerInputs }
            , Cmd.none
            , Registered token
            )

        RegisterComplete Nothing ->
            ( { model
                | errors =
                    [ "Something went wrong while registering your information. Please try again later." ]
              }
            , Cmd.none
            , Continue
            )

        SwitchFormMode formMode ->
            ( { model | formMode = formMode }
            , Cmd.none
            , Continue
            )


empty : Model
empty =
    { registerInputs =
        { name = ""
        , email = ""
        , password = ""
        }
    , formMode = RegisterForm
    , errors = []
    }


registerValidator : Verify.Validator String RegisterInputs RegisterInputs
registerValidator =
    Verify.validate RegisterInputs
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
        , viewRegisterForm model.registerInputs
        ]


viewRegisterForm : RegisterInputs -> Html Msg
viewRegisterForm inputs =
    Html.form
        [ Events.onSubmit Register ]
        [ Html.styled Html.p
            [ Ui.bodyCopyStyle ]
            []
            [ Html.text "Already registered? "
            , Html.styled Html.a
                [ Ui.linkStyle ]
                [ Events.onClick (SwitchFormMode LoginForm) ]
                [ Html.text "Log in" ]
            , Html.text " instead."
            ]
        , styledTextInput "name"
            |> TextInput.withLabel "Your Name"
            |> TextInput.withPlaceholder "Cool Speaker Person"
            |> TextInput.withValue inputs.name
            |> TextInput.onInput UpdateName
            |> TextInput.view
        , emailInput
            |> TextInput.withValue inputs.email
            |> TextInput.view
        , passwordInput
            |> TextInput.withValue inputs.password
            |> TextInput.view
        , Html.styled Html.input
            [ Ui.buttonStyle ]
            [ Attributes.type_ "submit" ]
            [ Html.text "Register" ]
        ]


emailInput : TextInput Msg
emailInput =
    styledTextInput "email"
        |> TextInput.withLabel "Your Email Address"
        |> TextInput.withPlaceholder "you@awesomeperson.com"
        |> TextInput.withType TextInput.Email
        |> TextInput.onInput UpdateEmail


passwordInput : TextInput Msg
passwordInput =
    styledTextInput "password"
        |> TextInput.withLabel "Your Password"
        |> TextInput.withType TextInput.Password
        |> TextInput.onInput UpdatePassword


styledTextInput : String -> TextInput String
styledTextInput =
    textInput
        >> TextInput.withStyle [ Css.margin2 (Css.px 30) Css.zero ]
