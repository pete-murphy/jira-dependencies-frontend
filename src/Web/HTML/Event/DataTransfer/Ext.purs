module Web.HTML.Event.DataTransfer.Ext
  ( items
  ) where

import Web.HTML.Event.DataTransfer (DataTransfer)
import Web.HTML.Event.DataTransfer.DataTransferItem (DataTransferItemList)

foreign import _items :: DataTransfer -> DataTransferItemList

items :: DataTransfer -> DataTransferItemList
items = _items
