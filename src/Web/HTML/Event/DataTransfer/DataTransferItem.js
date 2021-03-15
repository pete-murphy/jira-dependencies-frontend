"use strict";

exports._kind = function (dataTransferItem) {
  return dataTransferItem.kind;
};

exports._type = function (dataTransferItem) {
  return dataTransferItem.type;
};

exports._dataTransferItem = function (index, dataTransferItemList) {
  return dataTransferItemList[index];
};

exports._length = function (dataTransferItemList) {
  return dataTransferItemList.length;
};