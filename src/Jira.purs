module Jira where

import Prelude
import Data.Array as Array
import Data.DotLang as DotLang
import Data.List (List, (:))
import Data.List.Lazy as List
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Number as Number
import Data.String as String
import Data.Traversable as Traversable
import Data.Tuple (Tuple(..))
import Data.Tuple as Tuple
import Data.Tuple.Nested (type (/\), (/\))
import DropInput (CSV(..))
import Partial.Unsafe as Unsafe

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
  parseAnnotatedIssue annotatedRow = do
    let
      annotatedRowMap = Map.fromFoldable annotatedRow
    issueKey <- Map.lookup "Issue key" annotatedRowMap
    let
      summary = Map.lookup "Summary" annotatedRowMap

      blocks =
        Array.filter (not <<< String.null) do
          Tuple.snd
            <$> Array.filter ((_ == "Outward issue link (Blocks)") <<< Tuple.fst) annotatedRow

      storyPoints =
        Map.lookup "Custom field (Story Points)" annotatedRowMap
          >>= Number.fromString

      status = Map.lookup "Status" annotatedRowMap

      issueType = Map.lookup "Issue Type" annotatedRowMap

      labels =
        Tuple.snd
          <$> Array.filter ((_ == "Labels") <<< Tuple.fst) annotatedRow
    pure
      ( Tuple issueKey
          { summary
          , blocks
          , storyPoints
          , status
          , issueType
          , labels
          , dummy: false
          }
      )
