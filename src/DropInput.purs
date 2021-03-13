module DropInput where

import Prelude
import Data.Either (Either(..))
import Data.Foldable as Foldable
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.List (List)
import Data.Nullable as Nullable
import Effect (Effect)
import Effect.Aff as Aff
import React.Basic.DOM as R
import React.Basic.DOM.Events as DOM.Events
import React.Basic.Events (SyntheticEvent)
import React.Basic.Events as Events
import React.Basic.Hooks (Component, (/\))
import React.Basic.Hooks as Hooks
import Text.Parsing.CSV as CSV
import Text.Parsing.Parser (ParseError)
import Text.Parsing.Parser as Parser
import Unsafe.Coerce as Coerce
import Web.File.File (File)
import Web.File.File as File
import Web.File.FileList as FileList
import Web.File.FileReader.Aff as FileReader.Aff
import Web.HTML.Event.DataTransfer as DataTransfer
import Web.HTML.Event.DragEvent (DragEvent)
import Web.HTML.Event.DragEvent as DragEvent
import Web.HTML.HTMLElement as HTMLElement
import Web.HTML.HTMLInputElement as HTMLInputElement

newtype CSV
  = CSV (List (List String))

derive newtype instance showCSV :: Show CSV

data ParsedState
  = Initial
  | ParseError ParseError
  | Success CSV

derive instance genericParsedState :: Generic ParsedState _

instance showParsedState :: Show ParsedState where
  show = genericShow

parseCSV :: String -> ParsedState
parseCSV str = case Parser.runParser str CSV.defaultParsers.file of
  Left parseError -> ParseError parseError
  Right csv -> Success (CSV csv)

mkDropInput :: Component (CSV -> Effect Unit)
mkDropInput =
  Hooks.component "DropInput" \handleCSV -> Hooks.do
    hover /\ setHover <- Hooks.useState' false
    parsedCSV /\ setParsedCSV <- Hooks.useState' Initial
    fileInputRef <- Hooks.useRef Nullable.null
    -- Hooks.useEffect file do
    --   Foldable.for_ file ?handleReadFile
    --   pure mempty
    -- where
    -- handleReadFile :: 
    let
      onButtonClick =
        Events.handler_ do
          maybeNode <- Hooks.readRefMaybe fileInputRef
          Foldable.for_ (HTMLElement.fromNode =<< maybeNode) \htmlElement -> do
            HTMLElement.click htmlElement

      handleReadFile :: File -> Effect Unit
      handleReadFile file' = do
        let
          blob = File.toBlob file'
        Aff.runAff_
          -- (setParsedCSV <<< Either.hush)
          (Foldable.traverse_ (setParsedCSV <<< parseCSV))
          (FileReader.Aff.readAsText blob)
    pure do
      R.div
        { style:
            R.css
              { display: "flex"
              , flexDirection: "column"
              , alignItems: "center"
              , justifyContent: "center"
              , margin: "min(8rem, calc(50vh - 6rem)) auto"
              , borderRadius: "1rem"
              , inlineSize: "32rem"
              , blockSize: "12rem"
              , borderWidth: "0.4rem"
              , borderStyle: "dashed"
              , borderColor: if hover then "purple" else "lightgray"
              }
        , onDragEnter:
            Events.handler_ do
              setHover true
        , onDragLeave:
            Events.handler_ do
              setHover false
        , onDragOver:
            DOM.Events.capture_ do
              setHover true
        , onDrop:
            Events.handler DOM.Events.preventDefault \e -> do
              setHover false
              let
                maybeFileList = DataTransfer.files (DragEvent.dataTransfer (toDragEvent e))
              Foldable.for_ (FileList.item 0 =<< maybeFileList) handleReadFile
        , children:
            [ R.button
                { onClick: onButtonClick
                , children: [ R.text "Upload CSV" ]
                }
            , R.input
                { ref: fileInputRef
                , hidden: true
                , type: "file"
                , multiple: true
                , accept: ".csv"
                , onChange:
                    Events.handler DOM.Events.currentTarget \target ->
                      Foldable.for_ (HTMLInputElement.fromEventTarget target) \fileInput -> do
                        maybeFileList <- HTMLInputElement.files fileInput
                        Foldable.for_ (FileList.item 0 =<< maybeFileList) handleReadFile
                }
            , R.pre
                { style:
                    R.css
                      { color: "gray"
                      , whiteSpace: "break-spaces"
                      , textAlign: "center"
                      , overflow: "hidden"
                      , textOverflow: "ellipsis"
                      , inlineSize: "100%"
                      }
                , children:
                    [ R.text (show { hover, parsedCSV })
                    ]
                }
            ]
        }

-- | We happen to know that we're dealing with a `DragEvent` where we're using this, but
-- | not every `SyntheticEvent` can be converted to a `DragEvent`, so this is a partial 
-- | function. A proper implementation of this would probably be typed 
-- |
-- | ```purs
-- | toDragEvent :: SyntheticEvent -> Maybe DragEvent
-- | ```
-- |
-- | and could use `Web.Internal.FFI.unsafeReadProtoTagged` to inspect the constructor
-- | of the event and verify that it is indeed a `DragEvent`.
toDragEvent :: SyntheticEvent -> DragEvent
toDragEvent = Coerce.unsafeCoerce
