port module Main exposing (main, speakerPage)

import Browser
import Color exposing (Color)
import Dict exposing (Dict)
import Head
import Head.OpenGraph as OpenGraph
import Head.SocialMeta as SocialMeta
import Html as RootHtml exposing (Html)
import Html.Styled as Html
import Json.Decode
import Json.Encode
import List.Extra
import Mark
import Page.Schedule
import Pages exposing (Page)
import Pages.Content as Content exposing (Content)
import Pages.Document
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.Path as Path
import PagesNew exposing (images)
import Ui
import Url exposing (Url)


main : Pages.Program Model Msg Metadata (Html.Html Msg)
main =
    PagesNew.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument, markupDocument ]
        , head = head
        , manifest = manifest
        }


markdownDocument : Pages.Document.DocumentParser Metadata (Html.Html Msg)
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = frontmatterParser
        , body = \content -> Ok (Ui.markdown content)
        }


markupDocument : Pages.Document.DocumentParser Metadata (Html.Html Msg)
markupDocument =
    Pages.Document.markupParser
        (Mark.document identity speakerMetadata)
        speakerPage


speakerPage : Mark.Document (Html.Html Msg)
speakerPage =
    Mark.documentWith (\metadata body -> Html.text "TODO (doc)")
        { metadata = speakerMetadata
        , body =
            Mark.manyOf
                [ Mark.textWith
                    { view = \_ _ -> Html.text "TODO (text)"
                    , replacements = Mark.commonReplacements
                    , inlines = []
                    }
                ]
        }


speakerMetadata : Mark.Block Metadata
speakerMetadata =
    Mark.record "Speaker"
        (\name photo -> SpeakerPage { name = name, photo = photo })
        |> Mark.field "name" Mark.string
        |> Mark.field "photo" Mark.string
        |> Mark.toBlock


manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.MinimalUi
    , orientation = Manifest.Portrait
    , description = siteTagline
    , iarcRatingId = Nothing
    , name = "elm-conf 2019"
    , themeColor = Just Color.white
    , startUrl = PagesNew.pages.schedule
    , shortName = Just "elm-conf 2019"
    , sourceIcon = images.elmLogo
    }


type Metadata
    = SpeakerPage
        { name : String
        , photo : String
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
            (Json.Decode.field "photo" Json.Decode.string)
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


view : Model -> List ( List String, Metadata ) -> Page Metadata (Html.Html Msg) -> { title : String, body : Html Msg }
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


pageView : Model -> List ( List String, Metadata ) -> Page Metadata (Html.Html Msg) -> { title : String, body : Html Msg }
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


rootUrl =
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
head : Metadata -> List Head.Tag
head metadata =
    case metadata of
        RegularPage page ->
            OpenGraph.website
                (OpenGraph.summaryLarge
                    { url = rootUrl
                    , siteName = siteName
                    , image =
                        { url = rootUrl ++ Path.toString images.elmLogo
                        , alt = "elm-conf logo"
                        , dimensions = Nothing
                        , mimeType = Nothing
                        }
                    , locale = Nothing
                    , description = page.description |> Maybe.withDefault siteTagline
                    , title = page.title
                    }
                )
                ++ [ Head.description (page.description |> Maybe.withDefault siteTagline)
                   ]
                ++ SocialMeta.summaryLarge
                    { title = page.title
                    , description = page.description |> Maybe.withDefault siteTagline |> Just
                    , image =
                        Just
                            { url = rootUrl ++ Path.toString images.elmLogo
                            , alt = "elm-conf logo"
                            }
                    , siteUser = Nothing
                    }

        SpeakerPage speaker ->
            OpenGraph.website
                (OpenGraph.summaryLarge
                    { url = rootUrl
                    , siteName = siteName
                    , image =
                        { url = rootUrl ++ speaker.photo
                        , alt = speaker.name
                        , dimensions = Nothing
                        , mimeType = Nothing
                        }
                    , locale = Nothing
                    , description = siteTagline
                    , title = speaker.name
                    }
                )
                ++ [ Head.description speaker.name
                   ]
                ++ SocialMeta.summaryLarge
                    { title = speaker.name
                    , description = Just siteTagline
                    , image =
                        Just
                            { url = rootUrl ++ speaker.photo
                            , alt = speaker.name
                            }
                    , siteUser = Nothing
                    }

        SchedulePage page ->
            OpenGraph.website
                (OpenGraph.summaryLarge
                    { url = rootUrl
                    , siteName = siteName
                    , image =
                        { url = rootUrl ++ Path.toString images.elmLogo
                        , alt = "elm-conf logo"
                        , dimensions = Nothing
                        , mimeType = Nothing
                        }
                    , description = siteTagline
                    , locale = Nothing
                    , title = page.title
                    }
                )
                ++ [ Head.description (page.description |> Maybe.withDefault siteTagline)
                   ]
