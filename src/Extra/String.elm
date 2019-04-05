module Extra.String exposing (wordCount)

import Regex


wordCount : String -> Int
wordCount =
    let
        regex =
            "\\s+"
                |> Regex.fromStringWith { caseInsensitive = True, multiline = True }
                |> Maybe.withDefault Regex.never
    in
    \string ->
        let
            trimmed =
                String.trim string
        in
        if String.isEmpty trimmed then
            0

        else
            trimmed
                |> Regex.split regex
                |> List.length
