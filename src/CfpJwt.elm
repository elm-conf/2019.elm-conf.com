module CfpJwt exposing (Token, decoder, fromFlags)

import Json.Decode as Decode exposing (Decoder)
import Jwt
import Time


type alias Token =
    { role : String
    , userId : Int
    , isReviewer : Bool
    , expires : Time.Posix
    }


decoder : Decoder Token
decoder =
    Decode.map4 Token
        (Decode.field "role" Decode.string)
        (Decode.field "user_id" Decode.int)
        (Decode.field "is_reviewer" Decode.bool)
        (Decode.field "exp" posixSeconds)


posixSeconds : Decoder Time.Posix
posixSeconds =
    Decode.map
        (\seconds -> Time.millisToPosix (seconds * 1000))
        Decode.int


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
