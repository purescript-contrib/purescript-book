"use strict";

exports.setItem = key => value => () =>
  window.localStorage.setItem(key, value);

exports.getItem = key => () =>
  window.localStorage.getItem(key);
