module URL where

import Prelude
import Data.Either as Either
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Data.Validation.Semigroup (V(..))
import Effect (Effect)

foreign import readEnv :: Effect Env

type Env
  = { urlPrefix :: Nullable String, urlSuffix :: Nullable String }

newtype MissingEnvVar
  = MissingEnvVar String

fromEnv :: Env -> V (Array MissingEnvVar) { urlPrefix :: String, urlSuffix :: String }
fromEnv env = ado
  urlPrefix <-
    V do
      Either.note
        [ MissingEnvVar "URL_PREFIX" ]
        (Nullable.toMaybe env.urlPrefix)
  urlSuffix <-
    V do
      Either.note
        [ MissingEnvVar "URL_SUFFIX" ]
        (Nullable.toMaybe env.urlSuffix)
  in { urlPrefix, urlSuffix }

makeCSVLinkURL :: Effect (V (Array MissingEnvVar) (String -> String))
makeCSVLinkURL =
  readEnv
    <#> fromEnv
    >>> map \{ urlPrefix, urlSuffix } epic -> urlPrefix <> epic <> urlSuffix
