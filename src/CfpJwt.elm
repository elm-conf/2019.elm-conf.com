module CfpJwt exposing (Token, decoder)

import Json.Decode as Decode exposing (Decoder)


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
