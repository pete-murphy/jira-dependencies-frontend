module Jira where

import Data.Maybe (Maybe)

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
