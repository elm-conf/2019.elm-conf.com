module ProposalString exposing (Bounds, ProposalString, Validation(..), blur, error, init, input, toString)

import Extra.String


type ProposalString
    = ProposalString
        { input : String
        , validation : Validation
        , everBlurred : Bool
        , error : Maybe String
        }


type Validation
    = NotBlank String
    | WithinBounds Bounds


type alias Bounds =
    { lower : Int
    , tooShortError : String
    , upper : Int
    , tooLongError : String
    }


init : Validation -> String -> ProposalString
init validation input =
    ProposalString
        { input = input
        , validation = validation
        , everBlurred = False
        , error = Nothing
        }


toString : ProposalString -> String
toString (ProposalString { input }) =
    input


error : ProposalString -> Maybe String
error (ProposalString existing) =
    existing.error


input : String -> ProposalString -> ProposalString
input input (ProposalString existing) =
    ProposalString
        { existing
            | input = input
            , error =
                if existing.everBlurred then
                    validate existing.validation input

                else
                    Nothing
        }


blur : ProposalString -> ProposalString
blur (ProposalString existing) =
    ProposalString { existing | everBlurred = True }


validate : Validation -> String -> Maybe String
validate validation input =
    case validation of
        NotBlank isBlankError ->
            if String.isEmpty (String.trim input) then
                Just isBlankError

            else
                Nothing

        WithinBounds bounds ->
            validateBounds bounds input


validateBounds : Bounds -> String -> Maybe String
validateBounds bounds input =
    let
        wordCount =
            Extra.String.wordCount input
    in
    if wordCount < bounds.lower then
        Just bounds.tooShortError

    else if wordCount > bounds.upper then
        Just bounds.tooLongError

    else
        Nothing
