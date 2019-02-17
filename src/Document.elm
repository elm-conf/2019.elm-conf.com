module Document exposing (demo, document)

import Browser
import Html
import Mark exposing (Block, Nested(..), Text)


demo =
    String.trim """
| Page
    title = Speak at elm-conf
    slug = speak

The quick facts:

| List
    - You can submit as many talks as you like.
    - Your talk will be reviewed anonymously by a small group (see "Anonymity" below.)
    - We're happy to give you feedback on your ideas before before you send them in: [email elm-conf@thestrangeloop.com](mailto:elm-conf@thestrangeloop.com).
    - We'll give you one round of feedback on your submitted talk if you submit before May 6 (one week before the deadline.)

| Heading
    level = first
    title = Talk Subjects and Format

The quick facts:
All talks submitted through the call for speakers will be 30 minutes long.
Talks will be recorded, but you will have the final say before we publish.
    """


document =
    Mark.document identity <|
        page


type alias Page =
    { title : String
    , slug : String
    , contents : List Content
    }


page : Block Page
page =
    Mark.startWith
        (\( title, slug ) contents -> Page title slug contents)
        (Mark.record2
            "Page"
            Tuple.pair
            (Mark.field "title" Mark.string)
            -- TODO: can we have a slug field computed instead of required?
            (Mark.field "slug" Mark.string)
        )
        body


type Content
    = Paragraph (List Text)
      -- TODO: wow, this is a bit of a messy type. Could it be neater?
    | ContentList (List (Nested (List (List Text))))
    | Heading HeadingLevel (List Text)


body : Block (List Content)
body =
    Mark.manyOf
        [ Mark.map ContentList <|
            Mark.block "List"
                (List.map (nestedMap Tuple.second))
                (Mark.nested
                    { item = text
                    , start = Mark.exactly "- " ()
                    }
                )
        , Mark.record2 "Heading"
            Heading
            (Mark.field "level" headingLevel)
            (Mark.field "title" text)
        , Mark.map Paragraph text
        ]


type HeadingLevel
    = First
    | Second
    | Third
    | Fourth
    | Fifth
    | Sixth


headingLevel : Block HeadingLevel
headingLevel =
    -- Yes, I know there are more levels than this, but for this particular
    -- case I want us never to explicitly use them!
    Mark.oneOf
        [ Mark.exactly "first" First
        , Mark.exactly "second" Second
        , Mark.exactly "third" Third
        , Mark.exactly "fourth" Fourth
        ]


nestedMap : (a -> b) -> Nested a -> Nested b
nestedMap fn (Nested { content, children }) =
    Nested
        { content = fn content
        , children = List.map (nestedMap fn) children
        }


text : Block (List Text)
text =
    Mark.text
        { view = identity
        , inlines = []
        , replacements = []
        }


main =
    Html.main_
        []
        [ Html.pre [] [ Html.text demo ]
        , case Mark.parse document demo of
            Err problems ->
                Html.div []
                    [ Html.text "Problems!"
                    , problems
                        |> List.map
                            (\problem ->
                                Html.li [] [ Html.text (Debug.toString problem) ]
                            )
                        |> Html.ul []
                    ]

            Ok stuff ->
                Html.div []
                    [ Html.text "Success!"
                    , Html.text (Debug.toString stuff)
                    ]
        ]
