module ValidatedString exposing
    ( ValidatedString, fromString
    , withNotBlank, withMinWords, withMaxWords
    , input, blur
    , toString, error
    )

{-|

@docs ValidatedString, fromString

@docs withNotBlank, withMinWords, withMaxWords

@docs input, blur

@docs toString, error

-}

import Extra.String


type ValidatedString
    = ValidatedString
        { input : String
        , validations : List Validation
        , everBlurred : Bool
        , error : Maybe String
        }



-- CONFIGURATION


fromString : String -> ValidatedString
fromString input_ =
    ValidatedString
        { input = input_
        , validations = []
        , everBlurred = False
        , error = Nothing
        }


type Validation
    = NotBlank String
    | MinWords Int String
    | MaxWords Int String


withNotBlank : String -> ValidatedString -> ValidatedString
withNotBlank errorMessage (ValidatedString state) =
    ValidatedString { state | validations = state.validations ++ [ NotBlank errorMessage ] }


withMinWords : Int -> String -> ValidatedString -> ValidatedString
withMinWords howMany errorMessage (ValidatedString state) =
    ValidatedString { state | validations = state.validations ++ [ MinWords howMany errorMessage ] }


withMaxWords : Int -> String -> ValidatedString -> ValidatedString
withMaxWords howMany errorMessage (ValidatedString state) =
    ValidatedString { state | validations = state.validations ++ [ MaxWords howMany errorMessage ] }



-- UPDATES


{-| Change the input. Does not validate immediately, unless `blur` has been
called at least once.
-}
input : String -> ValidatedString -> ValidatedString
input input_ (ValidatedString state) =
    ValidatedString
        { state
            | input = input_
            , error =
                if state.everBlurred then
                    validate state.validations input_

                else
                    Nothing
        }


{-| Mark the input as being blurred—validate immediately.
-}
blur : ValidatedString -> ValidatedString
blur (ValidatedString state) =
    ValidatedString
        { state
            | everBlurred = True
            , error = validate state.validations state.input
        }



-- READING


toString : ValidatedString -> String
toString (ValidatedString state) =
    state.input


error : ValidatedString -> Maybe String
error (ValidatedString state) =
    state.error



-- INTERNALS


validate : List Validation -> String -> Maybe String
validate validations input_ =
    case validations of
        [] ->
            Nothing

        validation :: rest ->
            case validateSingle validation input_ of
                Just error_ ->
                    Just error_

                Nothing ->
                    validate rest input_


validateSingle : Validation -> String -> Maybe String
validateSingle validation input_ =
    case validation of
        NotBlank errorMessage ->
            if String.isEmpty (String.trim input_) then
                Just errorMessage

            else
                Nothing

        MinWords howMany errorMessage ->
            if Extra.String.wordCount input_ < howMany then
                Just errorMessage

            else
                Nothing

        MaxWords howMany errorMessage ->
            if Extra.String.wordCount input_ > howMany then
                Just errorMessage

            else
                Nothing
