module Jira where

import Prelude
import Color (Color)
import Control.Monad.State (State)
import Control.Monad.State as State
import Data.Array as Array
import Data.DotLang (Definition(..), Edge(..), EdgeType(..), Graph(..), Node(..))
import Data.DotLang as DotLang
import Data.DotLang.Attr (FillStyle)
import Data.DotLang.Attr.Edge as Edge
import Data.DotLang.Attr.Node as Node
import Data.DotLang.Class as DotLang.Class
import Data.Int as Int
import Data.List (List, (:))
import Data.List.Lazy as List
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Maybe as Maybe
import Data.Number as Number
import Data.String (Pattern(..))
import Data.String as String
import Data.Traversable (class Traversable)
import Data.Traversable as Traversable
import Data.Tuple (Tuple(..))
import Data.Tuple as Tuple
import Data.Tuple.Nested (type (/\), (/\))
import Data.Unfoldable as Unfoldable
import DropInput (CSV(..))
import Partial.Unsafe as Unsafe
import React.Basic.DOM (summary)
import Unsafe.Coerce (unsafeCoerce)

type IssueKey
  = String

type Issue
  = { summary :: Maybe String
    , blocks :: Array IssueKey
    , storyPoints :: Maybe Number
    , status :: Maybe String
    , issueType :: Maybe String
    , labels :: Array String
    , dummy :: Boolean
    }

parseIssues :: CSV -> Maybe (Map IssueKey Issue)
parseIssues (CSV inputCSV) = do
  annotatedRows <- maybeAnnotatedRows
  annotatedIssues <- Traversable.traverse parseAnnotatedIssue annotatedRows
  pure (Map.fromFoldable annotatedIssues)
  where
  maybeAnnotatedRows :: Maybe (Array (Array (String /\ String)))
  maybeAnnotatedRows = case inputCSV of
    header : rows ->
      Just do
        Array.zip (Array.fromFoldable header)
          <$> Array.fromFoldable (Array.fromFoldable <$> rows)
    _ -> Nothing

  parseAnnotatedIssue :: Array (String /\ String) -> Maybe (IssueKey /\ Issue)
  parseAnnotatedIssue annotatedRow = ado
    issueKey <- Map.lookup "Issue key" annotatedRowMap
    in Tuple issueKey
      { summary
      , blocks
      , storyPoints
      , status
      , issueType
      , labels
      , dummy: false
      }
    where
    annotatedRowMap = Map.fromFoldable annotatedRow

    summary = Map.lookup "Summary" annotatedRowMap

    blocks =
      Array.mapMaybe
        (\(header /\ value) -> if header == "Outward issue link (Blocks)" && value /= "" then Just value else Nothing)
        annotatedRow

    storyPoints =
      Map.lookup "Custom field (Story Points)" annotatedRowMap
        >>= Number.fromString

    status = Map.lookup "Status" annotatedRowMap

    issueType = Map.lookup "Issue Type" annotatedRowMap

    labels =
      Array.mapMaybe
        (\(header /\ value) -> if header == "Labels" then Just value else Nothing)
        annotatedRow

mkLabelledNode ::
  { name :: String
  , label :: String
  , color :: Color
  , style :: FillStyle
  , penWidth :: Number
  } ->
  Node
mkLabelledNode { name, label, color, style, penWidth } =
  Node name
    [ Node.Label (Node.TextLabel label)
    , Node.Style style
    , Node.FillColor color
    , Node.PenWidth penWidth
    ]

mkEdge :: { from :: String, to :: String } -> Edge
mkEdge { from, to } = Edge Forward from to []

mkGraph :: Array Node -> Array Edge -> Graph
mkGraph = DotLang.graphFromElements

printGraph :: Graph -> String
printGraph = DotLang.Class.toText

-- Convert Issues to a Graph
displayNumber :: Number -> String
displayNumber n = case Int.fromNumber n of
  Just n' -> show n'
  Nothing -> show n

toNode :: (IssueKey /\ Issue) -> Node
toNode (issueKey /\ { summary, blocks, storyPoints, status, issueType, labels, dummy }) = do
  mkLabelledNode { name: issueKey, label, color, style, penWidth }
  where
  label
    | dummy = ""
    | otherwise =
      String.joinWith "\n" do
        [ String.joinWith " " do
            (Unfoldable.fromMaybe storyPoints <#> \x -> ("(" <> displayNumber x <> ")"))
              <> Maybe.maybe [] (wrapText 30) summary
        ]

  wrapText :: Int -> String -> Array String
  wrapText charLimit str =
    flip State.execState [] do
      Traversable.for (String.split (Pattern " ") str) \word ->
        State.state do
          -- maybeLast <- State.gets Array.last
          -- case maybeLast of
          --   Just last -> if length last + length word > charLimit then do
          --     State.modify (_ <> word) else State.
          pure (unit /\ []) -- TODO

  -- flip State.evalState  do
  --   pure []
  color = unsafeCoerce unit

  style = unsafeCoerce unit

  penWidth = case issueType of
    Just "Story" -> 3.0
    _ -> 1.0

--   = unlines
--   $ [unwords ( [issueId]
--             ++ ["(" ++ showDouble x ++ ")" | x <- toList storyPoints]
--              )]
--  ++ maybe [] (wrapText 30) summary
-- wrapText :: Int -> String -> [String]
-- wrapText charLimit = go [] . words
--   where
--     go :: [String] -> [String] -> [String]
--     go [] [] = []
--     go line [] = [unwords line]
--     go [] (word:words)
--       = go [word] words
--     go line (word:words)
--       = let line' = line ++ [word]
--             charLength = length (unwords line')
--         in if charLength > charLimit
--            then unwords line : go [] (word:words)
--            else go line' words
-- color = case status of
--   Nothing
--     -> "white"
--   Just "To Do"
--     -> "white"
--   Just "Done"
--     -> "darkolivegreen1"
--   Just "Won't Fix"
--     -> "gainsboro"
--   Just _  -- probably "In Progress" or "QA"
--     -> "#f1ffdb"  -- between white and darkolivegreen1
-- style = if "stretch-goal" `elem` labels || issueType == Just "Tech Debt"
--         then "dashed"
--         else "solid"
