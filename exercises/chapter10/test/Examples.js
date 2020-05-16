"use strict";

exports.square = function (n) {
  return n * n;
};


exports.diagonal = function (w, h) {
  return Math.sqrt(w * w + h * h);
};

exports.diagonalNested = function (w) {
  return function (h) {
    return Math.sqrt(w * w + h * h);
  };
};

exports.diagonalArrow = w => h =>
  Math.sqrt(w * w + h * h);


exports.cumulativeSums = arr => {
  let sum = 0
  let sums = []
  arr.forEach(x => {
    sum += x;
    sums.push(sum);
  });
  return sums;
};


exports.addComplex = a => b => {
  return {
    real: a.real + b.real,
    imag: a.imag + b.imag
  }
};

exports.maybeHeadImpl = just => nothing => arr => {
  if (arr.length) {
    return just(arr[0]);
  } else {
    return nothing;
  }
};

exports.undefinedHead = arr =>
  arr[0];

exports.isUndefined = value =>
  value === undefined;

exports.unsafeHead = arr => {
  if (arr.length) {
    return arr[0];
  } else {
    throw new Error('unsafeHead: empty array');
  }
};


exports.boldImpl = show => x =>
  show(x).toUpperCase() + "!!!";

exports.showEqualityImpl = eq => show => a => b => {
  if (eq(a)(b)) {
    return "Equivalent";
  } else {
    return show(a) + " is not equal to " + show(b);
  }
}

exports.yellImpl = show => x => () =>
  console.log(show(x).toUpperCase() + "!!!");

exports.diagonalLog = function (w, h) {
  let result = Math.sqrt(w * w + h * h);
  console.log("Diagonal is " + result);
  return result;
};

const wait = ms => new Promise(resolve => setTimeout(resolve, ms));

exports.sleepImpl = ms => () =>
  wait(ms);

async function diagonalWait(delay, w, h) {
  await wait(delay);
  return Math.sqrt(w * w + h * h);
}

exports.diagonalAsyncImpl = delay => w => h => () =>
  diagonalWait(delay, w, h);


exports.cumulativeSumsBroken = arr => {
  let sum = 0
  let sums = []
  arr.forEach(x => {
    sum += x;
    sums.push(sum);
  });
  sums.push("Broken"); // Bug
  return sums;
};


exports.addComplexBroken = a => b => {
  return {
    real: a.real + b.real,
    broken: a.imag + b.imag // Bug
  }
};

exports.cumulativeSumsJson = exports.cumulativeSumsBroken
// Try the non-broken version too
//exports.cumulativeSumsJson = exports.cumulativeSums

exports.addComplexJson = exports.addComplexBroken
// Try the non-broken version too
//exports.addComplexJson = exports.addComplex


exports.mapSetFooJson = j => {
  let m = new Map(j);
  m.set("Foo", 42);
  return Array.from(m);
};

/*
These versions always point to either the working or broken versions
to enable automated testing.
The examples accompanying the text are meant to be swapped
between versions by the reader.
*/
exports.cumulativeSumsJsonBroken = exports.cumulativeSumsBroken
exports.addComplexJsonBroken = exports.addComplexBroken
exports.cumulativeSumsJsonWorking = exports.cumulativeSums
exports.addComplexJsonWorking = exports.addComplex