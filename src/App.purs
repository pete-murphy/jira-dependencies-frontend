module App where

import Prelude
import CustomHooks as CustomHooks
import Data.Either (Either(..))
import Data.String as String
import Data.Validation.Semigroup as V
import DropInput as DropInput
import Graph as Graph
import React.Basic.DOM as R
import React.Basic.DOM.Events as DOM.Events
import React.Basic.Hooks (Component, (/\))
import React.Basic.Hooks as Hooks
import URL (MissingEnvVar(..))
import URL as URL

mkApp :: Component Unit
mkApp = do
  dropInput <- DropInput.mkDropInput
  graph <- Graph.mkGraph
  maybeMakeCSVLinkURL <- URL.makeCSVLinkURL
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
            , case String.null epic, V.toEither maybeMakeCSVLinkURL of
                false, Right makeCSVLinkURL ->
                  R.a
                    { href: makeCSVLinkURL epic
                    , children: [ R.text (makeCSVLinkURL epic) ]
                    }
                true, Left errs ->
                  R.p
                    { className: "error"
                    , children:
                        errs
                          <#> \(MissingEnvVar err) ->
                              R.li_ [ R.text err ]
                    }
                _, _ -> mempty
            , dropInput setGraphString
            ]
        _ -> graph graphString
