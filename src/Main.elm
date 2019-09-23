port module Main exposing (main, markupPage)

import Browser
import Color exposing (Color)
import Css
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Html.Styled.Attributes as Attributes exposing (css)
import Json.Decode
import Json.Encode
import List.Extra
import Mark
import Page.Schedule
import Pages exposing (images)
import Pages.Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Ui
import Url exposing (Url)


main : Pages.Platform.Program Model Msg Metadata (Html.Html Msg)
main =
    Pages.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument, markupDocument ]
        , head = head
        , manifest = manifest
        , canonicalSiteUrl = "https://2019.elm-conf.com"
        }


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata (Html.Html Msg) )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = frontmatterParser
        , body = \content -> Ok (Ui.markdown content)
        }


markupDocument : ( String, Pages.Document.DocumentHandler Metadata (Html.Html Msg) )
markupDocument =
    Pages.Document.markupParser
        (Mark.document identity speakerMetadata)
        markupPage


markupPage : Mark.Document (Html.Html Msg)
markupPage =
    Mark.manyOf
        [ Mark.map
            (Html.p
                [ css
                    [ Ui.bodyCopyStyle
                    , Ui.pStyle
                    ]
                ]
            )
            markupText
        , Mark.record "H1"
            (Html.h1 [ css [ Ui.h1Style ] ])
            |> Mark.field "text" markupText
            |> Mark.toBlock
        , Mark.record "H2"
            (Html.h2 [ css [ Ui.h2Style ] ])
            |> Mark.field "text" markupText
            |> Mark.toBlock
        , Mark.record "YouTube"
            (\id ->
                Html.div
                    [ css
                        [ Css.position Css.relative
                        , Css.paddingBottom (Css.pct 56.25)
                        , Css.height Css.zero
                        , Css.overflow Css.hidden
                        , Css.maxWidth (Css.pct 100)
                        , Css.marginBottom (Css.px 10)
                        ]
                    ]
                    [ Html.iframe
                        [ Attributes.src ("https://www.youtube-nocookie.com/embed/" ++ id)
                        , Attributes.attribute "frameBorder" "0"
                        , Attributes.attribute "allowFullscreen" "true"
                        , css
                            [ Css.position Css.absolute
                            , Css.top Css.zero
                            , Css.left Css.zero
                            , Css.width (Css.pct 100)
                            , Css.height (Css.pct 100)
                            ]
                        ]
                        []
                    ]
            )
            |> Mark.field "id" Mark.string
            |> Mark.toBlock
        ]
        |> Mark.document (Html.section [])


markupText : Mark.Block (List (Html.Html Msg))
markupText =
    Mark.textWith
        { view = \styles text -> styledText (stylesFromMarkStyles styles) text
        , replacements = Mark.commonReplacements
        , inlines = []
        }


type Style
    = Bold
    | Italic
    | Strike


stylesFromMarkStyles : Mark.Styles -> List Style
stylesFromMarkStyles { bold, italic, strike } =
    [ ( Bold, bold )
    , ( Italic, italic )
    , ( Strike, strike )
    ]
        |> List.filter Tuple.second
        |> List.map Tuple.first


styledText : List Style -> String -> Html.Html msg
styledText styles text =
    case styles of
        [] ->
            Html.text text

        Bold :: rest ->
            Html.strong [] [ styledText rest text ]

        Italic :: rest ->
            Html.em [] [ styledText rest text ]

        Strike :: rest ->
            Html.s [] [ styledText rest text ]


speakerMetadata : Mark.Block Metadata
speakerMetadata =
    Mark.record "Speaker"
        (\name photo -> SpeakerPage { name = name, photo = photo })
        |> Mark.field "name" Mark.string
        |> Mark.field "photo" imageField
        |> Mark.toBlock


imageField =
    Mark.string
        |> Mark.verify
            (\imageAssetPath ->
                case findMatchingImage imageAssetPath of
                    Nothing ->
                        Err
                            { title = "Couldn't find image."
                            , message = [ imageAssetPath ++ " is not a valid image." ]
                            }

                    Just imagePath ->
                        Ok imagePath
            )


findMatchingImage : String -> Maybe (ImagePath Pages.PathKey)
findMatchingImage imageAssetPath =
    Pages.allImages
        |> List.Extra.find
            (\image ->
                ImagePath.toString image
                    == imageAssetPath
            )


manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.MinimalUi
    , orientation = Manifest.Portrait
    , description = siteTagline
    , iarcRatingId = Nothing
    , name = "elm-conf 2019"
    , themeColor = Just Color.white
    , startUrl = Pages.pages.schedule
    , shortName = Just "elm-conf 2019"
    , sourceIcon = images.elmLogo
    }


type Metadata
    = SpeakerPage
        { name : String
        , photo : ImagePath Pages.PathKey
        }
    | RegularPage
        { title : String
        , description : Maybe String
        }
    | SchedulePage
        { title : String
        , description : Maybe String
        }


frontmatterParser : Json.Decode.Decoder Metadata
frontmatterParser =
    Json.Decode.oneOf
        [ Json.Decode.map2
            (\name photo ->
                SpeakerPage
                    { name = name
                    , photo = photo
                    }
            )
            (Json.Decode.field "title" Json.Decode.string)
            (Json.Decode.field "photo" imageDecoder)
        , Json.Decode.maybe (Json.Decode.field "type" Json.Decode.string)
            |> Json.Decode.andThen
                (\type_ ->
                    let
                        constructor =
                            if type_ == Just "schedule" then
                                SchedulePage

                            else
                                RegularPage
                    in
                    Json.Decode.map2
                        (\title description ->
                            constructor
                                { title = title
                                , description = description
                                }
                        )
                        (Json.Decode.field "title" Json.Decode.string)
                        (Json.Decode.field "description" Json.Decode.string |> Json.Decode.maybe)
                )
        ]


imageDecoder : Json.Decode.Decoder (ImagePath Pages.PathKey)
imageDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\imageAssetPath ->
                case findMatchingImage imageAssetPath of
                    Nothing ->
                        Json.Decode.fail "Couldn't find image."

                    Just imagePath ->
                        Json.Decode.succeed imagePath
            )


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


type Msg
    = SetFocus String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata (Html.Html Msg) Pages.PathKey -> { title : String, body : Html Msg }
view model siteMetadata page =
    let
        { title, body } =
            pageView model siteMetadata page

        photo =
            case page.metadata of
                SpeakerPage speaker ->
                    Just speaker.photo

                _ ->
                    Nothing

        content =
            case page.metadata of
                SchedulePage _ ->
                    Page.Schedule.view page.view

                _ ->
                    page.view

        -- case model.route of
        --     Just Routes.Cfp ->
        --         Cfp.view model.cfp >> Html.map CfpMsg
        --
        --     Just Routes.CfpProposals ->
        --         Proposals.view model.proposals >> Html.map ProposalsMsg
        --
        --     Just Routes.Register ->
        --         Register.view model.register >> Html.map RegisterChanged
        --
        --     Just Routes.Schedule ->
        --         Schedule.view
        --
        --     _ ->
        --         Ui.markdown
        -- |> List.singleton
    in
    { title = title
    , body =
        Ui.page
            { setFocus = SetFocus
            , photo = photo
            , title = title
            , content = content
            }
            |> Html.toUnstyled
    }


pageView : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata (Html.Html Msg) Pages.PathKey -> { title : String, body : Html Msg }
pageView model siteMetadata page =
    case page.metadata of
        RegularPage metadata ->
            { title = metadata.title
            , body =
                page.view
                    |> Html.toUnstyled
            }

        SpeakerPage metadata ->
            { title = metadata.name
            , body =
                page.view
                    |> Html.toUnstyled
            }

        SchedulePage metadata ->
            { title = metadata.title
            , body =
                page.view
                    |> Html.toUnstyled
            }


canonicalSiteUrl =
    "https://2019.elm-conf.com"


siteTagline =
    "elm-conf is a one-day conference for the Elm programming language, returning September 12 2019 to St. Louis, MO."


siteName =
    "elm-conf 2019"


{-| <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
<https://htmlhead.dev>
<https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
<https://ogp.me/>
-}
head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        RegularPage page ->
            Seo.website
                (Seo.summaryLarge
                    { canonicalUrlOverride = Nothing
                    , siteName = siteName
                    , image =
                        { url = images.elmLogo
                        , alt = "elm-conf logo"
                        , dimensions = Nothing
                        , mimeType = Nothing
                        }
                    , locale = Nothing
                    , description = page.description |> Maybe.withDefault siteTagline
                    , title = page.title
                    }
                )

        SpeakerPage speaker ->
            Seo.website
                (Seo.summaryLarge
                    { canonicalUrlOverride = Nothing
                    , siteName = siteName
                    , image =
                        { url = speaker.photo
                        , alt = speaker.name
                        , dimensions = Nothing
                        , mimeType = Nothing
                        }
                    , locale = Nothing
                    , description = siteTagline
                    , title = speaker.name
                    }
                )

        SchedulePage page ->
            Seo.website
                (Seo.summaryLarge
                    { canonicalUrlOverride = Nothing
                    , siteName = siteName
                    , image =
                        { url = images.elmLogo
                        , alt = "elm-conf logo"
                        , dimensions = Nothing
                        , mimeType = Nothing
                        }
                    , description = siteTagline
                    , locale = Nothing
                    , title = page.title
                    }
                )
