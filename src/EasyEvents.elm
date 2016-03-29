module EasyEvents (onInput, onEnterPress, onSpecificKeyPress, onChange) where

{-|
# Event helpers
@docs onInput, onSpecificKeyPress, onEnterPress, onChange
-}

import Html exposing (Html)
import Html.Events exposing (on, targetValue, onKeyPress)
import Html.Attributes exposing (..)
import Signal exposing (message, Address)
import Json.Decode as Decode exposing (customDecoder, Decoder, (:=))
import Result
import String


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


{-| Like `onInput`, but for Ints instead of Strings
-}
onInputInt : Address action -> (Int -> action) -> Html.Attribute
onInputInt address actionCreator =
  on
    "input"
    targetValue
    (\str ->
      let
        int =
          Result.withDefault 0 (String.toInt str)
      in
        message address (actionCreator int)
    )


{-| Like `onInput`, but for Floats instead of Strings
-}
onInputFloat : Address action -> (Float -> action) -> Html.Attribute
onInputFloat address actionCreator =
  on
    "input"
    targetValue
    (\str ->
      let
        float =
          Result.withDefault 0.0 (String.toFloat str)
      in
        message address (actionCreator float)
    )


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


{-| Takes an address of a type, and a function that produces a value of that
type from a string. That value will be send to the address in a message
when a "change" event is fired.

You'll probably use this to send an action to your update function when
an HTML `select` is changed.
-}
onChange : Address a -> (String -> a) -> Html.Attribute
onChange address fn =
  on "change" targetValue (\val -> Signal.message address (fn val))
