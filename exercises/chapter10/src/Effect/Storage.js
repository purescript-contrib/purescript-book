"use strict";

export const setItem = key => value => () =>
  window.localStorage.setItem(key, value);

export const getItem = key => () =>
  window.localStorage.getItem(key);
