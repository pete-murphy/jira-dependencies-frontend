module Web.HTML.Event.DataTransfer.Ext
  ( items
  , types
  ) where

import Web.HTML.Event.DataTransfer (DataTransfer)
import Web.HTML.Event.DataTransfer.DataTransferItem (DataTransferItemList)

foreign import _items :: DataTransfer -> DataTransferItemList

foreign import _types :: DataTransfer -> Array String

items :: DataTransfer -> DataTransferItemList
items = _items

types :: DataTransfer -> Array String
types = _types
