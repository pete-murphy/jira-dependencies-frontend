module Main where

import Prelude
import App as App
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception as Exception
import React.Basic.DOM as React.Basic.DOM
import Web.DOM.NonElementParentNode as NonElementParentNode
import Web.HTML as HTML
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window as Window

main :: Effect Unit
main = do
  window <- HTML.window
  document <- HTMLDocument.toNonElementParentNode <$> Window.document window
  maybeRootNode <- NonElementParentNode.getElementById "root" document
  case maybeRootNode of
    Nothing -> Exception.throw "Element with ID 'root' not found."
    Just rootNode -> do
      app <- App.mkApp
      React.Basic.DOM.render (app unit) rootNode
