port module Main exposing (Msg(..), main, update, view)

import Browser
import Browser.Dom exposing (Viewport)
import Html exposing (Html, a, div, h1, h3, text)
import Html.Attributes exposing (class, href, id, style)
import Html.Events exposing (preventDefaultOn)
import Json.Decode as D
import Task


port onPopState : (() -> msg) -> Sub msg


port onUrlChange : (() -> msg) -> Sub msg


port getLocation : () -> Cmd msg


port gotLocation : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg


type alias Flags =
    String


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions _ =
    Sub.batch
        [ onPopState PopState
        , onUrlChange UrlChanged
        , gotLocation GotLocation
        ]


type alias History =
    { previous : Viewport
    , beforePrevious : Viewport
    }


type Model
    = Top History
    | Polano History
    | MilkyTrain History
    | RainWind History
    | NotFound History


toHistory : Model -> History
toHistory model =
    case model of
        Top hs ->
            hs

        Polano hs ->
            hs

        MilkyTrain hs ->
            hs

        RainWind hs ->
            hs

        NotFound hs ->
            hs


updateHistory : History -> Model -> Model
updateHistory hs model =
    case model of
        Top _ ->
            Top hs

        Polano _ ->
            Polano hs

        MilkyTrain _ ->
            MilkyTrain hs

        RainWind _ ->
            RainWind hs

        NotFound _ ->
            NotFound hs


defaultViewport : Viewport
defaultViewport =
    { scene =
        { width = 0
        , height = 0
        }
    , viewport =
        { x = 0
        , y = 0
        , width = 0
        , height = 0
        }
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( locationHrefToModel { previous = defaultViewport, beforePrevious = defaultViewport } flags
    , Cmd.batch
        [-- [ Task.perform GotViewPort <| Task.map (\t -> Ok t) <| Browser.Dom.getViewport
        ]
    )


type Msg
    = PopState ()
    | UrlChanged ()
    | GotLocation String
    | Clicked String
    | GotViewPort Viewport
    | NoOp



-- | GotViewPort (Result Never Viewport)


locationHrefToModel : History -> String -> Model
locationHrefToModel hs here =
    if here == "http://localhost:1234/" then
        Top hs

    else if here == "http://localhost:1234/polano-square" then
        Polano hs

    else if here == "http://localhost:1234/milky-train" then
        MilkyTrain hs

    else if here == "http://localhost:1234/rain-wind" then
        RainWind hs

    else
        NotFound hs


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        hs =
            toHistory model
    in
    case msg of
        PopState here ->
            ( model
              -- ( locationHrefToModel here
            , Cmd.batch
                [--                [ Task.perform GotViewPortP Browser.Dom.getViewport
                ]
            )

        UrlChanged here ->
            ( model
              -- ( locationHrefToModel here
            , Cmd.batch
                [ Task.perform GotViewPort Browser.Dom.getViewport
                ]
            )

        Clicked url ->
            ( model
            , Cmd.batch
                [ pushUrl url

                -- , Task.perform GotViewPort <| Task.map (\t -> Ok t) <| Browser.Dom.getViewport
                ]
            )

        GotViewPort viewport ->
            let
                nextHs =
                    { previous = viewport, beforePrevious = hs.previous }
            in
            ( updateHistory nextHs model, getLocation () )

        GotLocation url ->
            ( locationHrefToModel hs url
            , Cmd.none
              -- このTaskのタイミングが違う
              -- , Task.perform (\_ -> NoOp) (Browser.Dom.setViewport vp.viewport.x vp.viewport.y)
            )

        NoOp ->
            ( model, Cmd.none )


type alias Page =
    { title : String, phrase : String }


topPage =
    div
        [ class "background top" ]
        [ h1 [] [ text "宮沢賢治" ]
        , link (Clicked "/polano-square") [ href "" ] [ text "ポラーノの広場" ]
        , link (Clicked "/milky-train") [ href "" ] [ text "銀河鉄道の夜" ]
        , link (Clicked "/rain-wind") [ href "" ] [ text "雨ニモマケズ風ニモマケズ" ]
        ]


polanoSquarePage =
    { title = "ポラーノの広場", phrase = "あのイーハトーヴォのすきとおった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモリーオ市、郊外のぎらぎらひかる草の波。" }


milkyTrainPage =
    { title = "銀河鉄道の夜", phrase = "カムパネルラ、また僕たち二人きりになったねえ、どこまでもどこまでも一緒に行こう。僕はもうあのさそりのようにほんとうにみんなの幸さいわいのためならば僕のからだなんか百ぺん灼やいてもかまわない。" }


rainWindPage =
    { title = "雨ニモマケズ風ニモマケズ", phrase = "雨ニモマケズ風ニモマケズ雪ニモ夏ノ暑サニモマケヌ丈夫ナカラダヲモチ慾ハナク決シテ瞋ラズイツモシヅカニワラッテヰル" }


view : Model -> Html Msg
view model =
    case model of
        NotFound _ ->
            div [] [ text "404 not found" ]

        Top _ ->
            topPage

        Polano viewport ->
            viewPage polanoSquarePage viewport

        MilkyTrain viewport ->
            viewPage milkyTrainPage viewport

        RainWind viewport ->
            viewPage rainWindPage viewport


viewPage : Page -> History -> Html Msg
viewPage page _ =
    let
        outer =
            page.phrase |> String.repeat 100
    in
    div [ class "background" ]
        [ h1 [] [ text page.title ]
        , h3 [] [ text "宮沢賢治" ]
        , div [] [ text outer ]
        ]


link : msg -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
link msg attrs children =
    a (preventDefaultOn "click" (D.map alwaysPreventDefault (D.succeed msg)) :: attrs) children


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )
