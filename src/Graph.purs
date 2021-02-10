module Graph
  ( makeGraph
  , Graph
  , Node
  , NodeKey(..)
  , useGraph
  ) where

import Prelude
import Effect (Effect)
import React.Basic.DOM as R
import React.Basic.DOM.SVG as S
import React.Basic.Hooks (Hook, JSX, UseEffect)
import React.Basic.Hooks as Hooks

type Graph
  = { nodes :: Array Node
    , edges :: Array { from :: NodeKey, to :: NodeKey }
    }

type Node
  = { key :: NodeKey
    , label :: String
    , fn :: String -> Effect Unit
    }

newtype NodeKey
  = NodeKey String

makeGraph :: Graph -> Effect Unit
makeGraph = _makeGraph

foreign import _makeGraph :: Graph -> Effect Unit

useGraph :: Graph -> Hook (UseEffect Unit) JSX
useGraph graph = Hooks.do
  Hooks.useEffectOnce do
    makeGraph graph
    pure mempty
  let
    svg =
      S.svg
        { width: "900"
        , height: "900"
        , style:
            R.css
              { outline: "1px solid red"
              }
        }
  pure svg
