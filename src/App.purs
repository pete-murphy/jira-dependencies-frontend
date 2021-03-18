module App where

import Prelude
import CustomHooks as CustomHooks
import Data.String as String
import DropInput as DropInput
import Effect.Class.Console as Console
import React.Basic.DOM as R
import React.Basic.DOM.Events as DOM.Events
import React.Basic.Hooks (Component, (/\))
import React.Basic.Hooks as Hooks
import URL as URL
import Graph as Graph

mkApp :: Component Unit
mkApp = do
  dropInput <- DropInput.mkDropInput
  graph <- Graph.mkGraph
  Hooks.component "App" \_ -> Hooks.do
    epic /\ setEpic <- CustomHooks.useInput ""
    graphString /\ setGraphString <- Hooks.useState' ""
    pure do
      case graphString of
        "" ->
          Hooks.fragment
            [ R.form
                { className: "epic-form"
                , onSubmit: DOM.Events.capture_ mempty -- TODO
                , children:
                    [ R.h1_ [ R.text "Jira Dependencies Frontend" ]
                    , R.label_
                        [ R.text "Epic"
                        , R.input
                            { value: epic
                            , onChange: setEpic
                            , placeholder: "e.g., PS-1234"
                            }
                        ]
                    ]
                }
            , R.p
                { style:
                    R.css
                      { display: "inline-block"
                      }
                , children:
                    [ if String.null epic then
                        mempty
                      else
                        R.a
                          { href: URL.makeCSVLinkURL epic
                          , children: [ R.text (URL.makeCSVLinkURL epic) ]
                          }
                    ]
                }
            , dropInput setGraphString
            ]
        _ -> graph graphString
