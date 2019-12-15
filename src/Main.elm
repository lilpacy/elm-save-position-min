port module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, input, text, a)
import Html.Attributes exposing (style, href)
import Html.Events exposing (onClick, onInput)
import Browser.Dom exposing (Viewport)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { value : String
    , viewport : Viewport
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { value = "type something below", viewport = { scene = { width = 0, height = 0 }, viewport = { x = 0, y = 0, width = 0, height = 0 } } }
    , Cmd.batch
        [
        ]
    )


type Msg
    = UpdateModel String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateModel value ->
            ( { model | value = value }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        outer = "あ" |> String.repeat 5000
        inner = "あ" |> String.repeat 1000
    in
    div []
        [ div [] [ text model.value ]
        , input [ onInput UpdateModel ] []
        , div [] [ text outer ]
        , div
            [ style "width" "200px"
            , style "height" "200px"
            , style "overflow-y" "scroll" ]
            [ text inner ]
        , a [ href "/" ] [ text "リンクだよ" ]
        ]
