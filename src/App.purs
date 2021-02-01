module App where

import Prelude
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Either as Either
import Data.Foldable (for_)
import Data.Maybe as Maybe
import Data.String.Base64 as Base64
import Effect.Aff (runAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log, logShow)
import Effect.Uncurried (EffectFn1)
import Milkis (URL(..), Fetch)
import Milkis as Milkis
import Milkis.Impl.Window as Milkis
import React.Basic.DOM as R
import React.Basic.DOM.Events as DOM.Events
import React.Basic.Events (EventHandler)
import React.Basic.Events as Events
import React.Basic.Hooks (Component, Hook, UseState, (/\), type (/\))
import React.Basic.Hooks as Hooks
import React.Basic.Hooks.Aff as Hooks.Aff

buildURL :: String -> URL
buildURL epic =
  Milkis.URL
    ( "https://ticket.simspace.com/sr/jira.issueviews:searchrequest-csv-all-fields/temp/SearchRequest.csv?jqlQuery=%22Epic+Link%22+%3D+"
        <> epic
        <> "&delimiter=,"
    )

fetch :: Fetch
fetch = Milkis.fetch Milkis.windowFetch

mkApp :: Component Unit
mkApp = do
  Hooks.component "App" \_ -> Hooks.do
    username /\ onChangeUsername <- useInput ""
    password /\ onChangePassword <- useInput ""
    epic /\ onChangeEpic <- useInput ""
    result /\ setResult <- Hooks.useState' (Left "")
    let
      onSubmit :: EventHandler
      onSubmit =
        Events.handler DOM.Events.preventDefault \_ -> do
          log "Heloo"
          let
            url = buildURL epic
          runAff_ (setResult <<< lmap show) do
            for_ (Base64.btoa (username <> ":" <> password)) \encodedString -> do
              res <-
                Milkis.text
                  =<< fetch url
                      { method: Milkis.getMethod
                      , headers:
                          Milkis.makeHeaders
                            { "Authorization": "Basic " <> encodedString
                            , "Content-Type": "application/json"
                            }
                      }
              logShow res
          pure unit
    pure
      ( R.div_
          [ R.form
              { onSubmit
              , children:
                  [ R.label_
                      [ R.text "Username"
                      , R.input
                          { onChange: onChangeUsername
                          , value: username
                          }
                      ]
                  , R.label_
                      [ R.text "Password"
                      , R.input
                          { onChange: onChangePassword
                          , type: "password"
                          , value: password
                          }
                      ]
                  , R.label_
                      [ R.text "Epic"
                      , R.input
                          { onChange: onChangeEpic
                          , value: epic
                          }
                      ]
                  , R.button_
                      [ R.text "Submit"
                      ]
                  ]
              }
          , R.div_
              [ R.pre_
                  [ R.text (show (Base64.btoa (username <> ":" <> password))) ]
              , R.pre_
                  [ R.text (show result) ]
              ]
          ]
      )

useInput :: String -> Hook (UseState String) (String /\ EventHandler)
useInput initialValue = Hooks.do
  value /\ setValue <- Hooks.useState' ""
  let
    onChange =
      Events.handler
        DOM.Events.targetValue \v ->
        (setValue (Maybe.fromMaybe "" v))
  pure (value /\ onChange)
