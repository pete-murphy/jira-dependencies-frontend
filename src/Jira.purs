module Jira
  ( csvToPrintedGraph
  , CSV(..)
  ) where

import Prelude
import Color (Color)
import Color as Color
import Control.Monad.State as State
import Data.Array as Array
import Data.Array as Foldable
import Data.DotLang (Edge(..), EdgeType(..), Graph, Node(..))
import Data.DotLang as DotLang
import Data.DotLang.Attr (FillStyle(..))
import Data.DotLang.Attr.Node as Node
import Data.DotLang.Class as DotLang.Class
import Data.Int as Int
import Data.Lens ((<>~))
import Data.Lens.Index as Index
import Data.Lens.Record as Record
import Data.List (List, (:))
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Maybe as Maybe
import Data.Number as Number
import Data.Set (Set)
import Data.Set as Set
import Data.String (Pattern(..))
import Data.String as String
import Data.Symbol (SProxy(..))
import Data.Traversable as Traversable
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested (type (/\), (/\))
import Data.Unfoldable as Unfoldable

newtype CSV
  = CSV (List (List String))

derive newtype instance showCSV :: Show CSV

derive newtype instance eqCSV :: Eq CSV

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
displayNumber num = case Int.fromNumber num of
  Just int -> show int
  Nothing -> show num

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
        ]
          <> Maybe.maybe [] (wrapText 30) summary

  wrapText :: Int -> String -> Array String
  wrapText charLimit str =
    flip State.execState [] do
      Traversable.for (String.split (Pattern " ") str) \word -> do
        let
          spaceAndWord = " " <> word
        last <- State.gets Array.last
        case String.length <$> last of
          Just runningLength
            | runningLength + String.length spaceAndWord <= charLimit ->
              State.modify do
                Index.ix (runningLength - 1) <>~ spaceAndWord
          _ ->
            State.modify do
              (_ <> [ word ])

  color = case status of
    Nothing -> Color.white
    Just "To Do" -> Color.white
    Just "Done" -> Color.hsl 82.0 0.39 0.3 -- darkolivegreen
    Just "Won't Fix" -> Color.hsl 0.0 0.0 86.3 -- gainsboro
    Just _ -> Color.hsl 23.0 1.00 0.93 -- between white and darkolivegreen

  style =
    if "stretch-goal" `Array.elem` labels || issueType == Just "Tech Debt" then
      Dotted
    else
      Filled

  penWidth = case issueType of
    Just "Story" -> 3.0
    _ -> 1.0

toEdges :: IssueKey /\ Issue -> Array Edge
toEdges (issueKey /\ { blocks }) = ado
  blockedIssueKey <- blocks
  in mkEdge { from: issueKey, to: blockedIssueKey }

toGraph :: Map IssueKey Issue -> Graph
toGraph issuesMap = mkGraph nodes edges
  where
  nodes = toNode <$> Map.toUnfoldable issuesMap

  edges = toEdges =<< Map.toUnfoldable issuesMap

addEdge :: { from :: IssueKey, to :: IssueKey } -> Map IssueKey Issue -> Map IssueKey Issue
addEdge { from, to } = Index.ix from <<< Record.prop (SProxy :: SProxy "blocks") <>~ [ to ]

-- | The tasks which are ready to start are those whose blocking tasks are
-- | completed (marked in green). This makes it difficult to see the tasks with
-- | in-degree zero, which are ready to be started but do not have green above
-- | them. So let's add a dummy green node above them.
markInitialNodes :: Map IssueKey Issue -> Map IssueKey Issue
markInitialNodes g = dummyNodes <> Foldable.foldr addEdge g dummyEdges
  where
  potentialNodes :: Map IssueKey Issue
  potentialNodes = Map.filter (\{ status } -> status `Array.elem` [ Nothing, Just "To Do" ]) g

  blockedNodes :: Set IssueKey
  blockedNodes = Set.unions (Set.fromFoldable <<< _.blocks <$> g)

  initialNodes :: Map IssueKey Issue
  initialNodes = Map.filterKeys (_ `Array.notElem` blockedNodes) potentialNodes

  mkDummyKey :: IssueKey -> IssueKey
  mkDummyKey = ("before-" <> _)

  mkDummyNode :: IssueKey /\ Issue -> IssueKey /\ Issue
  mkDummyNode (issueKey /\ { labels }) = do
    mkDummyKey issueKey
      /\ { summary: Nothing
        , blocks: [ issueKey ]
        , storyPoints: Nothing
        , status: Just "Done"
        , issueType: Nothing
        , labels
        , dummy: true
        }

  mkDummyEdge :: IssueKey -> { from :: IssueKey, to :: IssueKey }
  mkDummyEdge issueKey = { from: mkDummyKey issueKey, to: issueKey }

  dummyNodes :: Map IssueKey Issue
  dummyNodes =
    Map.fromFoldable do
      mkDummyNode <$> (Map.toUnfoldable initialNodes :: Array _)

  dummyEdges :: Array { from :: IssueKey, to :: IssueKey }
  dummyEdges = mkDummyEdge <$> Set.toUnfoldable (Map.keys initialNodes)

csvToPrintedGraph :: CSV -> Maybe String
csvToPrintedGraph csv =
  parseIssues csv
    <#> markInitialNodes
    >>> toGraph
    >>> printGraph
