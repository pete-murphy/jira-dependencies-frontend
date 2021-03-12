module App where

import Prelude
import CustomHooks as CustomHooks
import React.Basic.DOM as R
import React.Basic.DOM.Events as DOM.Events
import React.Basic.Events as Events
import React.Basic.Hooks (Component, (/\))
import React.Basic.Hooks as Hooks

mkApp :: Component Unit
mkApp = do
  Hooks.component "App" \_ -> Hooks.do
    epic /\ setEpic <- CustomHooks.useInput ""
    pure do
      R.form
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
            , R.button
                { onClick: Events.handler_ mempty -- TODO
                , children: [ R.text "Get CSV" ]
                }
            ]
        }
