module ValidatedString exposing
    ( ValidatedString, fromString
    , withNotBlank, withMinWords, withMaxWords
    , input, validate
    , toString, error
    )

{-|

@docs ValidatedString, fromString

@docs withNotBlank, withMinWords, withMaxWords

@docs input, validate

@docs toString, error

-}

import Extra.String


type ValidatedString
    = ValidatedString
        { input : String
        , validations : List Validation
        , enableValidation : Bool
        , error : Maybe String
        }



-- CONFIGURATION


fromString : String -> ValidatedString
fromString input_ =
    ValidatedString
        { input = input_
        , validations = []
        , enableValidation = False
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


{-| Change the input. Does not validate immediately, unless `validate` has been
called at least once.
-}
input : String -> ValidatedString -> ValidatedString
input input_ (ValidatedString state) =
    ValidatedString
        { state
            | input = input_
            , error =
                if state.enableValidation then
                    performValidation state.validations input_

                else
                    Nothing
        }


{-| Validate immediately, for instance on blur.
-}
validate : ValidatedString -> ValidatedString
validate (ValidatedString state) =
    ValidatedString
        { state
            | enableValidation = True
            , error = performValidation state.validations state.input
        }



-- READING


toString : ValidatedString -> String
toString (ValidatedString state) =
    state.input


error : ValidatedString -> Maybe String
error (ValidatedString state) =
    state.error



-- INTERNALS


performValidation : List Validation -> String -> Maybe String
performValidation validations input_ =
    case validations of
        [] ->
            Nothing

        validation :: rest ->
            case validateSingle validation input_ of
                Just error_ ->
                    Just error_

                Nothing ->
                    performValidation rest input_


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
