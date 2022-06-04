"use strict";

// ANCHOR: square
export const square = function (n) {
  return n * n;
};
// ANCHOR_END: square

// ANCHOR: diagonal
export const diagonal = function (w) {
  return function (h) {
    return Math.sqrt(w * w + h * h);
  };
};
// ANCHOR_END: diagonal

// ANCHOR: diagonal_arrow
export const diagonalArrow = w => h =>
  Math.sqrt(w * w + h * h);
// ANCHOR_END: diagonal_arrow

// ANCHOR: diagonal_uncurried
export const diagonalUncurried = function (w, h) {
  return Math.sqrt(w * w + h * h);
};
// ANCHOR_END: diagonal_uncurried

export const cumulativeSums = arr => {
  
  let sum = 0
  let sums = []
  arr.forEach(x => {
    sum += x;
    sums.push(sum);
  });
  return sums;
};


export const addComplex = a => b => {
  return {
    real: a.real + b.real,
    imag: a.imag + b.imag
  }
};

export const maybeHeadImpl = just => nothing => arr => {
  if (arr.length) {
    return just(arr[0]);
  } else {
    return nothing;
  }
};

export const undefinedHead = arr =>
  arr[0];

export const isUndefined = value =>
  value === undefined;

export const unsafeHead = arr => {
  if (arr.length) {
    return arr[0];
  } else {
    throw new Error('unsafeHead: empty array');
  }
};


export const boldImpl = show => x =>
  show(x).toUpperCase() + "!!!";

export const showEqualityImpl = eq => show => a => b => {
  if (eq(a)(b)) {
    return "Equivalent";
  } else {
    return show(a) + " is not equal to " + show(b);
  }
}

export const yellImpl = show => x => () =>
  console.log(show(x).toUpperCase() + "!!!");

export const diagonalLog = function (w, h) {
  let result = Math.sqrt(w * w + h * h);
  console.log("Diagonal is " + result);
  return result;
};

const wait = ms => new Promise(resolve => setTimeout(resolve, ms));

export const sleepImpl = ms => () =>
  wait(ms);

async function diagonalWait(delay, w, h) {
  await wait(delay);
  return Math.sqrt(w * w + h * h);
}

export const diagonalAsyncImpl = delay => w => h => () =>
  diagonalWait(delay, w, h);


export const cumulativeSumsBroken = arr => {
  let sum = 0
  let sums = []
  arr.forEach(x => {
    sum += x;
    sums.push(sum);
  });
  sums.push("Broken"); // Bug
  return sums;
};


export const addComplexBroken = a => b => {
  return {
    real: a.real + b.real,
    broken: a.imag + b.imag // Bug
  }
};

export const cumulativeSumsJson = cumulativeSumsBroken
// Try the non-broken version too
//export const cumulativeSumsJson = cumulativeSums

export const addComplexJson = addComplexBroken
// Try the non-broken version too
//export const addComplexJson = addComplex


export const mapSetFooJson = j => {
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
export const cumulativeSumsJsonBroken = cumulativeSumsBroken
export const addComplexJsonBroken = addComplexBroken
export const cumulativeSumsJsonWorking = cumulativeSums
export const addComplexJsonWorking = addComplex
