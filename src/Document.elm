module Document exposing (demo, document)

-- TODO: those exports don't make any sense. Whatever.

import Browser
import Document.Heading as Heading
import Html exposing (Html)
import Html.Attributes as Attrs
import Mark exposing (Block, Inline(..), Nested(..), Text(..))


demo =
    String.trim """
| Page
    title = Speak at elm-conf
    slug = speak

The quick facts:

| List
    - You can submit as many talks as you like.
    - Your talk will be reviewed anonymously by a small group (see "Anonymity" below.)
    - We're happy to give you feedback on your ideas before before you send them in: {Link|url=mailto:elm-conf@thestrangeloop.com|email elm-conf@thestrangeloop.com}.
    - We'll give you one round of feedback on your submitted talk if you submit before May 6 (one week before the deadline.)

| Heading
    level = first
    title = Talk Subjects and Format

All talks submitted through the call for speakers will be 30 minutes long.
Talks will be recorded, but you will have the final say before we publish.

Successful proposals tend to fall in one of these groups:

| List
    - *Case Studies:* How do you use Elm at work? For clients? As a part of your larger open-source project?

    - *Personal Projects:* What are you working on that excites you?

    - *Multidisciplinary:* Have you done something cool with Elm and graphics? Music? Hardware?

    - *Teaching:* Have you thought of a fun way to teach a concept? What mistake did you keep making until you learned X? What could people do if they just knew about Y?

That said, the best elm-conf talks are a mix of practical and philosophical, and we'll be happy to see any proposal that tells us both /what/ and /why/.
These categories are provided to help you brainstorm and are not a closed list of what we'll accept.
If you have an idea that falls outside what's specified here, send it in anyway!
We love being surprised!

A special note for maintainers: we welcome talks about your particular corner of the Elm ecosystem and the plans you have for your packages.
See the note under "Anonymity" at the bottom of this page.

However, elm-conf talk submissions should not be speculative about what /other people/ might do, and should not specifically pressure anyone to change direction or prioritization.
The one-way nature of the elm-conf stage makes it unsuitable for debate.
If you have suggestions for what the language and ecosystem might do in the future, {Link|url=(https://discourse.elm-lang.org)|Discourse} and the {Link|url=http://elmlang.herokuapp.com/|Elm Slack}, are more appropriate venues.

In addition, we probably won't accept:

| List
    - talks about category theory or other high-level mathematical concepts
    - talks solely about how Elm is insufficient or bad
    - talks about non-Elm related frontend work
    - talks that are not about Elm

| Heading
    level = first
    title = Speaking at elm-conf

A conference can't happen without speakers, so we want to do right by you.
If we accept your proposal, we'll:

| List
    - give you a ticket to elm-conf and Strange Loop
    - fly you to St. Louis (round-trip for continental US speakers, and a stipend for international travel)
    - book you a hotel room close to the venue for the duration of the conference
    - work with you to make a great talk with optional practice sessions and feedback from previous years' speakers.
    - invite you to a speakers dinner prior to the conference

We also want to make sure we're representing you well, so you will get the final say on your bio, photo, and the eventual publication of your talk.
(Although all talks will be recorded, we can and have declined to publish recordings in the past.
Publication is always opt-in.)

| Heading
    level = second
    title = First-time speakers

If you're a first time conference speaker, you still have a really good shot of getting in.
Our community gets stronger the more new and diverse voices there are, so we want to hear from you!
In fact, we are reserving several slots for first-time speakers.

If you are comfortable being identified as a new speaker for the purposes of the call for speakers, please indicate that in the `First time speaker` field on {Link|url=https://cfp.elm-conf.us/events/elm-conf-2018|your proposal}.
This is not required if you don't want to be identified in this way.

Once accepted, we will help you give your first conference talk.
This includes talk structure, practice sessions, and access to more experienced speakers to talk about about what works well.

You will also be invited to the speaker dinner.
We encourage you to attend this; it's a nice time to get to know your fellow speakers better.

We will also make sure you get a chance to become familiar with the venue before the audience is there—this helps calm jitters more than you'd think!

If you are new to writing conference proposals and would like to work with a speaker from a prior elm-conf to get feedback prior to submitting, please {Link|url=mailto:elm-conf@thestrangeloop.com|email us} or contact {Link|url=https://elmlang.slack.com/messages/D1KMC1AQ1/|@brianhicks} or {Link|url=https://elmlang.slack.com/messages/D0KEQUU9Z/|@luke} on the Elm Slack ({Link|url=http://elmlang.herokuapp.com/|sign up here}.)
We'll be happy to pair you with a previous year's speaker or answer any questions you have about the process.

| Heading
    level = first
    title = How Anonymous Proposals Work

The first pass of talk evaluation is done anonymously by a group of Elm community members and external observers.
We do this to give everyone the fairest shot possible at being accepted, and to avoid picking the same speakers every year.
We've had a lot of success with this; it's given us a nice mix of veteran and first-time speakers on tons of great topics over the years.

That said, we recognize that any process involving humans will be imperfect.
The Elm community is fairly small and sometimes it's impossible to avoid putting identifying information in a proposal.
If you find yourself in that situation, focus on making a /high-quality/ proposal over an /anonymized/ one.
We lean on the committee members outside the Elm community here; they can give these proposals the fairest shot.
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
    = Paragraph (List InlineContent)
      -- TODO: wow, this is a bit of a messy type. Could it be neater?
    | ContentList (List (Nested (List (List InlineContent))))
    | Heading Heading.Level (List InlineContent)


body : Block (List Content)
body =
    Mark.manyOf
        [ list
        , heading
        , paragraph
        ]


list : Block Content
list =
    Mark.map ContentList <|
        Mark.block "List"
            (List.map (nestedMap Tuple.second))
            (Mark.nested
                { item = text
                , start = Mark.exactly "- " ()
                }
            )


heading : Block Content
heading =
    Mark.record2 "Heading"
        Heading
        (Mark.field "level" Heading.levelBlock)
        (Mark.field "title" text)


paragraph : Block Content
paragraph =
    Mark.map Paragraph text


nestedMap : (a -> b) -> Nested a -> Nested b
nestedMap fn (Nested { content, children }) =
    Nested
        { content = fn content
        , children = List.map (nestedMap fn) children
        }


type InlineContent
    = Rich (List Mark.Style) String
    | Link
        { url : String
        , title : List InlineContent
        }


textToRich : Text -> InlineContent
textToRich (Text styles content) =
    Rich styles content


text : Block (List InlineContent)
text =
    Mark.text
        { view = textToRich
        , inlines = [ link ]
        , replacements = []
        }


link : Inline InlineContent
link =
    Mark.inline "Link"
        (\url title ->
            Link
                { url = url
                , title = List.map textToRich title
                }
        )
        |> Mark.inlineString "url"
        |> Mark.inlineText


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

            Ok page_ ->
                Html.div []
                    [ Html.text "Success!"
                    , view page_
                    ]
        ]



-- VIEW


view : Page -> Html msg
view { title, contents } =
    Html.div
        []
        (Html.h1 [] [ Html.text title ] :: List.map viewContent contents)


viewContent : Content -> Html msg
viewContent content =
    case content of
        Paragraph stuff ->
            Html.p [] (List.map viewInlineContent stuff)

        ContentList items ->
            Html.ul [] (List.map viewItem items)

        Heading level title ->
            Heading.viewAtLevel level
                []
                (List.map viewInlineContent title)


viewInlineContent : InlineContent -> Html msg
viewInlineContent inlineContent =
    case inlineContent of
        Rich styles content ->
            List.foldl
                (\format root ->
                    case format of
                        Mark.Bold ->
                            Html.strong [] [ root ]

                        Mark.Italic ->
                            Html.em [] [ root ]

                        Mark.Strike ->
                            Html.del [] [ root ]
                )
                (Html.text content)
                styles

        Link { url, title } ->
            Html.a
                [ Attrs.href url ]
                (List.map viewInlineContent title)


viewItem : Nested (List (List InlineContent)) -> Html text
viewItem (Nested { content, children }) =
    let
        contentView =
            content
                |> List.concat
                |> List.map viewInlineContent

        childrenView =
            List.map
                (\child -> Html.ul [] [ viewItem child ])
                children
    in
    Html.li [] (contentView ++ childrenView)
