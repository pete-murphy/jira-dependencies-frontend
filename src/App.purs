module App where

import Prelude
import Effect.Class.Console (log)
import Graph (Graph, NodeKey(..), useGraph)
import React.Basic.Hooks (Component)
import React.Basic.Hooks as Hooks

mkApp :: Component Unit
mkApp = do
  Hooks.component "App" \_ -> Hooks.do
    svg <- useGraph graph
    pure svg

-- Test data
graph :: Graph
graph =
  { nodes:
      [ { label: "Label A"
        , key: NodeKey "A"
        , fn: log
        }
      , { label: "Testing once agains"
        , key: NodeKey "B"
        , fn: log
        }
      , { label: "What"
        , key: NodeKey "C"
        , fn: log
        }
      ]
  , edges:
      [ { to:
            NodeKey "B"
        , from:
            NodeKey "A"
        }
      , { to:
            NodeKey "C"
        , from:
            NodeKey "A"
        }
      ]
  }
