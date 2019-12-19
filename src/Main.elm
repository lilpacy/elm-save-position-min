port module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, a, div, h1, h3, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (preventDefaultOn)
import Json.Decode as D


port onUrlChange : (() -> msg) -> Sub msg


port getLocation : () -> Cmd msg


port gotLocation : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg


port setOffsets : () -> Cmd msg


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
        [ onUrlChange UrlChanged
        , gotLocation GotLocation
        ]


type Model
    = Top
    | Polano
    | MilkyTrain
    | RainWind
    | NotFound


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( locationHrefToModel flags
    , Cmd.none
    )


type Msg
    = UrlChanged ()
    | GotLocation String
    | Clicked String
    | NoOp



-- | GotViewPort (Result Never Viewport)


locationHrefToModel : String -> Model
locationHrefToModel here =
    if here == "http://localhost:1234/" then
        Top

    else if here == "http://localhost:1234/polano-square" then
        Polano

    else if here == "http://localhost:1234/milky-train" then
        MilkyTrain

    else if here == "http://localhost:1234/rain-wind" then
        RainWind

    else
        NotFound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged _ ->
            ( model
            , Cmd.batch
                [ getLocation ()
                ]
            )

        Clicked url ->
            ( model
            , pushUrl url
              -- Task.perform GotViewPort <| Task.map (\t -> Ok t) <| Browser.Dom.getViewport
            )

        GotLocation url ->
            ( locationHrefToModel url
            , setOffsets ()
              -- Task.perform (\_ -> NoOp) (Browser.Dom.setViewport vp.viewport.x vp.viewport.y)
            )

        NoOp ->
            ( model, Cmd.none )


type alias Page =
    { title : String, phrase : String }


topPage =
    div
        [ class "background top" ]
        [ h1 [] [ text "宮沢賢治" ]
        , link (Clicked "http://localhost:1234/polano-square") [ href "" ] [ text "ポラーノの広場" ]
        , link (Clicked "http://localhost:1234/milky-train") [ href "" ] [ text "銀河鉄道の夜" ]
        , link (Clicked "http://localhost:1234/rain-wind") [ href "" ] [ text "雨ニモマケズ風ニモマケズ" ]
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
        NotFound ->
            div [] [ text "404 not found" ]

        Top ->
            topPage

        Polano ->
            viewPage polanoSquarePage

        MilkyTrain ->
            viewPage milkyTrainPage

        RainWind ->
            viewPage rainWindPage


viewPage : Page -> Html Msg
viewPage page =
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
