"use strict";

exports._items = function (dataTransfer) {
  return dataTransfer.items;
};

exports._types = function (dataTransfer) {
  return dataTransfer.types;
};