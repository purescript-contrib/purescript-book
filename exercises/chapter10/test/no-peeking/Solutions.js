"use strict";

export const volumeFn = function (x, y, z) {
  return x * y * z;
}

export const volumeArrow = x => y => z =>
  x * y * z;

export const cumulativeSumsComplex = arr => {
  let sum = { real: 0, imag: 0 }
  let sums = []
  arr.forEach(x => {
    sum = {
      real: sum.real + x.real,
      imag: sum.imag + x.imag
    };
    sums.push(sum);
  });
  return sums;
};

export const quadraticRootsImpl = mkPair => poly => {
  let { a, b, c } = poly;
  let radicand = b * b - 4 * a * c;
  if (radicand >= 0) {
    let rt = Math.sqrt(radicand);
    return mkPair
      ({ real: (-b + rt) / (2 * a), imag: 0 })
      ({ real: (-b - rt) / (2 * a), imag: 0 });
  } else {
    let rt = Math.sqrt(-radicand);
    return mkPair
      ({ real: -b / (2 * a), imag: rt / (2 * a) })
      ({ real: -b / (2 * a), imag: -rt / (2 * a) });
  }
};

export const toMaybeImpl = just => nothing => undefined$ => {
  if (undefined$ === undefined) {
    return nothing
  } else {
    return just(undefined$)
  }
}

export const valuesOfMapJson = j => {
  let m = new Map(j);
  let s = new Set(m.values())
  return Array.from(s);
};

export const quadraticRootsSetJson = poly => {
  let { a, b, c } = poly;
  let radicand = b * b - 4 * a * c;
  if (radicand >= 0) {
    let rt = Math.sqrt(radicand);
    return Array.from(new Set([
      { real: (-b + rt) / (2 * a), imag: 0 },
      { real: (-b - rt) / (2 * a), imag: 0 }]));
  } else {
    let rt = Math.sqrt(-radicand);
    return Array.from(new Set([
      { real: -b / (2 * a), imag: rt / (2 * a) },
      { real: -b / (2 * a), imag: -rt / (2 * a) }]));
  }
};

export const quadraticRootsSafeJson = poly => {
  let { a, b, c } = poly;
  let radicand = b * b - 4 * a * c;
  if (radicand >= 0) {
    let rt = Math.sqrt(radicand);
    return [
      { real: (-b + rt) / (2 * a), imag: 0 },
      { real: (-b - rt) / (2 * a), imag: 0 }];
  } else {
    let rt = Math.sqrt(-radicand);
    return [
      { real: -b / (2 * a), imag: rt / (2 * a) },
      { real: -b / (2 * a), imag: -rt / (2 * a) }];
  }
};
