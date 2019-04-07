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
    , loginInputs : LoginInputs
    , formMode : FormMode
    , errors : List String
    }


type alias RegisterInputs =
    { name : String
    , email : String
    , password : String
    }


type alias LoginInputs =
    { email : String
    , password : String
    }


type Msg
    = UpdateName String
    | UpdateEmail String
    | UpdatePassword String
    | Register
    | Login
    | RegisterComplete (Maybe String)
    | LoginComplete (Maybe String)
    | SwitchFormMode FormMode


type FormMode
    = LoginForm
    | RegisterForm


type ParentMsg
    = Continue
    | Authenticated String


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


login : String -> LoginInputs -> Cmd (Maybe String)
login url inputs =
    SelectionSet.succeed identity
        |> SelectionSet.with ApiAuthPayload.jwtToken
        |> ApiMutation.authenticate
            { input = ApiInputObject.buildAuthenticateInput inputs identity }
        |> SelectionSet.map (Maybe.andThen identity)
        |> SelectionSet.map (Maybe.map (\(ApiScalar.JwtToken s) -> s))
        |> Http.mutationRequest url
        |> Http.toTask
        |> Task.attempt (Result.toMaybe >> Maybe.andThen identity)


update : Env -> Msg -> Model -> ( Model, Cmd Msg, ParentMsg )
update env msg ({ registerInputs, loginInputs } as model) =
    case ( model.formMode, msg ) of
        ( _, UpdateName name ) ->
            ( { model | registerInputs = { registerInputs | name = name } }
            , Cmd.none
            , Continue
            )

        ( RegisterForm, UpdateEmail email ) ->
            ( { model | registerInputs = { registerInputs | email = email } }
            , Cmd.none
            , Continue
            )

        ( LoginForm, UpdateEmail email ) ->
            ( { model | loginInputs = { loginInputs | email = email } }
            , Cmd.none
            , Continue
            )

        ( RegisterForm, UpdatePassword password ) ->
            ( { model | registerInputs = { registerInputs | password = password } }
            , Cmd.none
            , Continue
            )

        ( LoginForm, UpdatePassword password ) ->
            ( { model | loginInputs = { loginInputs | password = password } }
            , Cmd.none
            , Continue
            )

        ( _, Register ) ->
            case registerValidator model.registerInputs of
                Ok valid ->
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

        ( _, RegisterComplete (Just token) ) ->
            ( { model | registerInputs = empty.registerInputs }
            , Cmd.none
            , Authenticated token
            )

        ( _, RegisterComplete Nothing ) ->
            ( { model
                | errors =
                    [ "Something went wrong while registering your information. Please try again later." ]
              }
            , Cmd.none
            , Continue
            )

        ( _, Login ) ->
            case loginValidator model.loginInputs of
                Ok valid ->
                    ( { model | loginInputs = valid, errors = [] }
                    , login env.graphqlUrl valid
                        |> Cmd.map LoginComplete
                    , Continue
                    )

                Err ( first, rest ) ->
                    ( { model | errors = first :: rest }
                    , Cmd.none
                    , Continue
                    )

        ( _, LoginComplete (Just token) ) ->
            ( { model | loginInputs = empty.loginInputs }
            , Cmd.none
            , Authenticated token
            )

        ( _, LoginComplete Nothing ) ->
            ( { model
                | errors =
                    [ "Something went wrong while logging in. Please check your password or try again later." ]
              }
            , Cmd.none
            , Continue
            )

        ( LoginForm, SwitchFormMode RegisterForm ) ->
            ( { model
                | formMode = RegisterForm
                , loginInputs = empty.loginInputs
                , registerInputs =
                    { registerInputs
                        | email = loginInputs.email
                        , password = loginInputs.password
                    }
              }
            , Cmd.none
            , Continue
            )

        ( RegisterForm, SwitchFormMode LoginForm ) ->
            ( { model
                | formMode = LoginForm
                , registerInputs = empty.registerInputs
                , loginInputs =
                    { loginInputs
                        | email = registerInputs.email
                        , password = registerInputs.password
                    }
              }
            , Cmd.none
            , Continue
            )

        ( _, SwitchFormMode _ ) ->
            ( model, Cmd.none, Continue )


empty : Model
empty =
    { registerInputs =
        { name = ""
        , email = ""
        , password = ""
        }
    , loginInputs =
        { email = ""
        , password = ""
        }
    , formMode = RegisterForm
    , errors = []
    }


registerValidator : Verify.Validator String RegisterInputs RegisterInputs
registerValidator =
    Verify.validate RegisterInputs
        |> Verify.verify .name (String.Verify.notBlank "Please enter your name. We need it to get in touch with you if your talk is selected.")
        |> verifyEmail
        |> verifyPassword


loginValidator : Verify.Validator String LoginInputs LoginInputs
loginValidator =
    Verify.validate LoginInputs
        |> verifyEmail
        |> verifyPassword


verifyEmail =
    Verify.verify .email (String.Verify.notBlank "Please enter your email address. We need it to get in touch with you for talk feedback and acceptance notifications.")


verifyPassword =
    Verify.verify .password (String.Verify.notBlank "Please set a password.")


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
        , case model.formMode of
            LoginForm ->
                viewLoginForm model.loginInputs

            RegisterForm ->
                viewRegisterForm model.registerInputs
        ]


viewRegisterForm : RegisterInputs -> Html Msg
viewRegisterForm inputs =
    Html.section []
        [ Html.styled Html.p
            [ Ui.bodyCopyStyle ]
            []
            [ Html.text "Already registered? "
            , switchButton "Log in" (SwitchFormMode LoginForm)
            , Html.text " instead."
            ]
        , Html.form
            [ Events.onSubmit Register ]
            [ styledTextInput "name"
                |> TextInput.withLabel "Your Name"
                |> TextInput.withPlaceholder "Cool Speaker Person"
                |> TextInput.withValue inputs.name
                |> TextInput.onEvents
                    { input = UpdateName
                    , blur = Nothing
                    }
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
        ]


viewLoginForm : LoginInputs -> Html Msg
viewLoginForm inputs =
    Html.section
        []
        [ Html.styled Html.p
            [ Ui.bodyCopyStyle ]
            []
            [ Html.text "Don't have a password? "
            , switchButton "Register" (SwitchFormMode RegisterForm)
            , Html.text " instead."
            ]
        , Html.form
            [ Events.onSubmit Login ]
            [ emailInput
                |> TextInput.withValue inputs.email
                |> TextInput.view
            , passwordInput
                |> TextInput.withValue inputs.password
                |> TextInput.view
            , Html.styled Html.input
                [ Ui.buttonStyle ]
                [ Attributes.type_ "submit" ]
                [ Html.text "Log in" ]
            ]
        ]


emailInput : TextInput Msg
emailInput =
    styledTextInput "email"
        |> TextInput.withLabel "Your Email Address"
        |> TextInput.withPlaceholder "you@awesomeperson.com"
        |> TextInput.withType TextInput.Email
        |> TextInput.onEvents
            { input = UpdateEmail
            , blur = Nothing
            }


passwordInput : TextInput Msg
passwordInput =
    styledTextInput "password"
        |> TextInput.withLabel "Your Password"
        |> TextInput.withType TextInput.Password
        |> TextInput.onEvents
            { input = UpdatePassword
            , blur = Nothing
            }


styledTextInput : String -> TextInput String
styledTextInput =
    textInput
        >> TextInput.withStyle [ Css.margin2 (Css.px 30) Css.zero ]


switchButton : String -> Msg -> Html Msg
switchButton caption msg =
    Html.styled Html.button
        [ Css.display Css.inline
        , Css.margin Css.zero
        , Css.padding Css.zero
        , Css.border Css.zero
        , Css.backgroundColor Css.transparent
        , Ui.bodyCopyStyle
        , Ui.linkStyle
        ]
        [ Events.onClick msg ]
        [ Html.text caption ]
