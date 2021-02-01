module App where

import Prelude
import Graph (Graph, NodeKey(..), makeGraph)
import React.Basic.DOM as R
import React.Basic.Hooks (Component, useEffectOnce)
import React.Basic.Hooks as Hooks

mkApp :: Component Unit
mkApp = do
  Hooks.component "App" \_ -> Hooks.do
    useEffectOnce do
      makeGraph graph
      pure mempty
    pure do
      R.div_ []

-- Test data
graph :: Graph
graph =
  { nodes:
      [ { label: "Label A"
        , key: NodeKey "A"
        }
      , { label: "Label very long label just a test"
        , key: NodeKey "B"
        }
      ]
  , edges:
      [ { to:
            NodeKey "B"
        , from:
            NodeKey "A"
        }
      ]
  }
