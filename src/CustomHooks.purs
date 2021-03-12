module CustomHooks (useInput) where

import Prelude
import Data.Foldable as Foldable
import React.Basic.DOM.Events as DOM.Events
import React.Basic.Events (EventHandler)
import React.Basic.Events as Events
import React.Basic.Hooks (type (/\), Hook, UseState, (/\))
import React.Basic.Hooks as Hooks

useInput :: String -> Hook (UseState String) (String /\ EventHandler)
useInput initialValue = Hooks.do
  value /\ setValue <- Hooks.useState' initialValue
  let
    onChange =
      Events.handler DOM.Events.targetValue \maybeValue ->
        Foldable.for_ maybeValue setValue
  pure (value /\ onChange)
