module Graph
  ( makeGraph
  , Graph
  , Node
  , NodeKey(..)
  ) where

import Prelude
import Effect (Effect)

type Graph
  = { nodes :: Array Node
    , edges :: Array { from :: NodeKey, to :: NodeKey }
    }

type Node
  = { key :: NodeKey
    , label :: String
    }

newtype NodeKey
  = NodeKey String

makeGraph :: Graph -> Effect Unit
makeGraph = _makeGraph

foreign import _makeGraph :: Graph -> Effect Unit
