"use strict";

exports.volumeFn = function (x, y, z) {
  return x * y * z;
}

exports.volumeArrow = x => y => z =>
  x * y * z;

exports.cumulativeSumsComplex = arr => {
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

exports.quadraticRootsImpl = mkPair => poly => {
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

exports.valuesOfMapJson = j => {
  let m = new Map(j);
  let s = new Set(m.values())
  return Array.from(s);
};

exports.quadraticRootsSetJson = poly => {
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

exports.quadraticRootsSafeJson = poly => {
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