module Graph (mkGraph) where

import Prelude
import Effect (Effect)
import React.Basic (ReactComponent)
import React.Basic.Hooks (Component)
import React.Basic.Hooks as Hooks

foreign import _mkGraph :: Effect (ReactComponent { graphString :: String })

mkGraph :: Component String
mkGraph = do
  graph <- _mkGraph
  Hooks.component "Graph" \graphString -> Hooks.do
    pure do
      Hooks.element graph { graphString }
