port module Main exposing (Msg(..), main, update, view)

import Browser
import Browser.Dom exposing (Viewport)
import Html exposing (Html, a, button, div, h1, h3, input, span, text)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick, onInput, preventDefaultOn)
import Json.Decode as D
import Task
import Url
import Url.Parser as Url


port onUrlChange : (String -> msg) -> Sub msg


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
    onUrlChange UrlChanged


type alias PreViewport =
    Viewport


type Model
    = Top PreViewport
    | Polano PreViewport
    | MilkyTrain PreViewport
    | RainWind PreViewport
    | NotFound PreViewport


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( locationHrefToModel flags
    , Cmd.batch
        [-- [ Task.perform GotViewPort <| Task.map (\t -> Ok t) <| Browser.Dom.getViewport
        ]
    )


type Msg
    = UrlChanged String
    | Clicked String
    | GotViewPort (Result Never Viewport)



-- | GotViewPort (Result Never Viewport)


locationHrefToModel : String -> Model
locationHrefToModel here =
    let
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
    in
    if here == "http://localhost:1234/" then
        Top defaultViewport

    else if here == "http://localhost:1234/polano-square" then
        Polano defaultViewport

    else if here == "http://localhost:1234/milky-train" then
        MilkyTrain defaultViewport

    else if here == "http://localhost:1234/rain-wind" then
        RainWind defaultViewport

    else
        NotFound defaultViewport


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged here ->
            ( locationHrefToModel here, Task.perform GotViewPort <| Task.map (\t -> Ok t) <| Browser.Dom.getViewport )

        Clicked url ->
            ( model, pushUrl url )

        GotViewPort (Ok viewport) ->
            case model of
                NotFound _ ->
                    ( NotFound viewport, Cmd.none )

                Top _ ->
                    ( Top viewport, Cmd.none )

                Polano _ ->
                    ( Polano viewport, Cmd.none )

                MilkyTrain _ ->
                    ( MilkyTrain viewport, Cmd.none )

                RainWind _ ->
                    ( RainWind viewport, Cmd.none )

        GotViewPort (Err _) ->
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


viewPage : Page -> PreViewport -> Html Msg
viewPage page _ =
    let
        outer =
            page.phrase |> String.repeat 100

        inner =
            page.phrase |> String.repeat 100
    in
    div [ class "background" ]
        [ h1 [] [ text page.title ]
        , h3 [] [ text "宮沢賢治" ]
        , div [] [ text outer ]
        , div
            [ style "width" "200px"
            , style "height" "200px"
            , style "overflow-y" "scroll"
            ]
            [ text inner ]
        ]


link : msg -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
link msg attrs children =
    a (preventDefaultOn "click" (D.map alwaysPreventDefault (D.succeed msg)) :: attrs) children


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )
