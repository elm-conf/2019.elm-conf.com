module CfpJwt exposing (Token, decoder, fromFlags)

import Json.Decode as Decode exposing (Decoder)
import Jwt


type alias Token =
    { role : String
    , userId : Int
    , isReviewer : Bool
    }


decoder : Decoder Token
decoder =
    Decode.map3 Token
        (Decode.field "role" Decode.string)
        (Decode.field "user_id" Decode.int)
        (Decode.field "is_reviewer" Decode.bool)


fromFlags : Maybe String -> Maybe ( String, Token )
fromFlags maybeMaterial =
    case maybeMaterial of
        Just material ->
            case Jwt.decodeToken decoder material of
                Ok token ->
                    Just ( material, token )

                Err _ ->
                    Nothing

        Nothing ->
            Nothing
