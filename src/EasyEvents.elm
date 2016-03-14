module EasyEvents (onInput, onEnterPress, onSpecificKeyPress) where

{-|
# Event helpers
@docs onInput, onSpecificKeyPress, onEnterPressed
-}

import Html exposing (Html)
import Html.Events exposing (on, targetValue, onKeyPress)
import Html.Attributes exposing (..)
import Signal exposing (message, Address)
import Json.Decode as Decode exposing (customDecoder, Decoder, (:=))
import Result


{-| Accepts an action, and a function that turns a string into an action.

Example:

```
type Action = UpdateName String

foo address model =
    input
        [ type' "text"
        , onInput address UpdateName
        , value model
        ]
```

The code above would send an UpdateName action to `adress` whenever an input
event is fired on the input element.
-}
onInput : Address action -> (String -> action) -> Html.Attribute
onInput address actionCreator =
    on "input" targetValue (\str -> message address (actionCreator str))


keyDecoder : Int -> Decoder Int
keyDecoder code =
    customDecoder
        Decode.int
        (\i ->
            if i == code then
                Result.Ok i
            else
                Result.Err ""
        )


{-| Takes an address, a key code, and an action. Sends the action to the address
whenever that specific key code is pressed with the parent element focused.

This is useful for reacting only to specific key-presses (like submitting a
form when the enter key is pressed, for example).
-}
onSpecificKeyPress : Address action -> Int -> action -> Html.Attribute
onSpecificKeyPress address code action =
    on
        "keypress"
        ("keyCode" := (keyDecoder code))
        (\_ -> message address action)


{-| Takes an address, and an action, and sends the action to the address only
when the enter key is pressed on the parent element.
-}
onEnterPress : Address action -> action -> Html.Attribute
onEnterPress address action =
    onSpecificKeyPress address 13 action
