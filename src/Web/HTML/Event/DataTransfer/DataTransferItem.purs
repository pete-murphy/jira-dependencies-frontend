module Web.HTML.Event.DataTransfer.DataTransferItem
  ( kind
  , type_
  , length
  , DataTransferItemKind
  , DataTransferItem
  , DataTransferItemList
  , dataTransferItem
  ) where

import Prelude
import Data.Function.Uncurried (Fn2)
import Data.Function.Uncurried as Uncurried
import Data.Maybe (Maybe)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Partial.Unsafe as Unsafe

foreign import _kind :: DataTransferItem -> String

foreign import _type :: DataTransferItem -> String

foreign import _dataTransferItem :: Fn2 Int DataTransferItemList (Nullable DataTransferItem)

foreign import _length :: DataTransferItemList -> Int

foreign import data DataTransferItem :: Type

foreign import data DataTransferItemList :: Type

-- | The drag data item kind
data DataTransferItemKind
  = Text
  | File

derive instance eqDataTransferItemKind :: Eq DataTransferItemKind

kind :: DataTransferItem -> DataTransferItemKind
kind item =
  Unsafe.unsafePartial case _kind item of
    "string" -> Text
    "file" -> File

type_ :: DataTransferItem -> String
type_ = _type

dataTransferItem :: Int -> DataTransferItemList -> Maybe DataTransferItem
dataTransferItem index list =
  Nullable.toMaybe
    (Uncurried.runFn2 _dataTransferItem index list)

length :: DataTransferItemList -> Int
length = _length
