module Page.Cfp.Proposals exposing (Model, Msg(..), empty, load, update, view)

import Html.Styled as Html exposing (Html)


type Model
    = Loading
    | Loaded LoadedModel
    | Failed


type alias LoadedModel =
    { end : Env
    , proposals : List ()
    }


type alias Env =
    { graphqlUrl : String
    , token : String
    }


type Msg
    = TODO


empty : Model
empty =
    Loading


load : Env -> ( Model, Cmd Msg )
load env =
    ( Loading
    , Cmd.none
    )


update : Env -> Msg -> Model -> ( Model, Cmd Msg )
update env _ model =
    ( model, Cmd.none )


view : Model -> String -> Html Msg
view model topContent =
    Html.text "hey"
