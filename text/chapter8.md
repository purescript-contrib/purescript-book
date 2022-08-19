# The Effect Monad

## Chapter Goals

In the last chapter, we introduced applicative functors, an abstraction which we used to deal with _side-effects_: optional values, error messages and validation. This chapter will introduce another abstraction for dealing with side-effects in a more expressive way: _monads_.

The goal of this chapter is to explain why monads are a useful abstraction, and their connection with _do notation_.

## Project Setup

The project adds the following dependencies:

- `effect` - defines the `Effect` monad, the subject of the second half of the chapter. This dependency is often listed in every starter project (it's been a dependency of every chapter so far), so you'll rarely have to explicitly install it.
- `react-basic-hooks` - a web framework that we will use for our Address Book app.

## Monads and Do Notation

Do notation was first introduced when we covered _array comprehensions_. Array comprehensions provide syntactic sugar for the `concatMap` function from the `Data.Array` module.

Consider the following example. Suppose we throw two dice and want to count the number of ways in which we can score a total of `n`. We could do this using the following non-deterministic algorithm:

- _Choose_ the value `x` of the first throw.
- _Choose_ the value `y` of the second throw.
- If the sum of `x` and `y` is `n` then return the pair `[x, y]`, else fail.

Array comprehensions allow us to write this non-deterministic algorithm in a natural way:

```hs
import Prelude

import Control.Plus (empty)
import Data.Array ((..))

{{#include ../exercises/chapter8/test/Examples.purs:countThrows}}
```

We can see that this function works in PSCi:

```text
> import Test.Examples

> countThrows 10
[[4,6],[5,5],[6,4]]

> countThrows 12
[[6,6]]
```

In the last chapter, we formed an intuition for the `Maybe` applicative functor, embedding PureScript functions into a larger programming language supporting _optional values_. In the same way, we can form an intuition for the _array monad_, embedding PureScript functions into a larger programming language supporting _non-deterministic choice_.

In general, a _monad_ for some type constructor `m` provides a way to use do notation with values of type `m a`. Note that in the array comprehension above, every line contains a computation of type `Array a` for some type `a`. In general, every line of a do notation block will contain a computation of type `m a` for some type `a` and our monad `m`. The monad `m` must be the same on every line (i.e. we fix the side-effect), but the types `a` can differ (i.e. individual computations can have different result types).

Here is another example of do notation, this time applied to the type constructor `Maybe`. Suppose we have some type `XML` representing XML nodes, and a function

```hs
child :: XML -> String -> Maybe XML
```

which looks for a child element of a node, and returns `Nothing` if no such element exists.

In this case, we can look for a deeply-nested element by using do notation. Suppose we wanted to read a user's city from a user profile which had been encoded as an XML document:

```hs
userCity :: XML -> Maybe XML
userCity root = do
  prof <- child root "profile"
  addr <- child prof "address"
  city <- child addr "city"
  pure city
```

The `userCity` function looks for a child element `profile`, an element `address` inside the `profile` element, and finally an element `city` inside the `address` element. If any of these elements are missing, the return value will be `Nothing`. Otherwise, the return value is constructed using `Just` from the `city` node.

Remember, the `pure` function in the last line is defined for every `Applicative` functor. Since `pure` is defined as `Just` for the `Maybe` applicative functor, it would be equally valid to change the last line to `Just city`.

## The Monad Type Class

The `Monad` type class is defined as follows:

```hs
class Apply m <= Bind m where
  bind :: forall a b. m a -> (a -> m b) -> m b

class (Applicative m, Bind m) <= Monad m
```

The key function here is `bind`, defined in the `Bind` type class. Just like for the `<$>` and `<*>` operators in the `Functor` and `Apply` type classes, the Prelude defines an infix alias `>>=` for the `bind` function.

The `Monad` type class extends `Bind` with the operations of the `Applicative` type class that we have already seen.

It will be useful to see some examples of the `Bind` type class. A sensible definition for `Bind` on arrays can be given as follows:

```hs
instance bindArray :: Bind Array where
  bind xs f = concatMap f xs
```

This explains the connection between array comprehensions and the `concatMap` function that has been alluded to before.

Here is an implementation of `Bind` for the `Maybe` type constructor:

```hs
instance bindMaybe :: Bind Maybe where
  bind Nothing  _ = Nothing
  bind (Just a) f = f a
```

This definition confirms the intuition that missing values are propagated through a do notation block.

Let's see how the `Bind` type class is related to do notation. Consider a simple do notation block which starts by binding a value from the result of some computation:

```hs
do value <- someComputation
   whatToDoNext
```

Every time the PureScript compiler sees this pattern, it replaces the code with this:

```hs
bind someComputation \value -> whatToDoNext
```

or, written infix:

```hs
someComputation >>= \value -> whatToDoNext
```

The computation `whatToDoNext` is allowed to depend on `value`.

If there are multiple binds involved, this rule is applied multiple times, starting from the top. For example, the `userCity` example that we saw earlier gets desugared as follows:

```hs
userCity :: XML -> Maybe XML
userCity root =
  child root "profile" >>= \prof ->
    child prof "address" >>= \addr ->
      child addr "city" >>= \city ->
        pure city
```

It is worth noting that code expressed using do notation is often much clearer than the equivalent code using the `>>=` operator. However, writing binds explicitly using `>>=` can often lead to opportunities to write code in _point-free_ form - but the usual warnings about readability apply.

## Monad Laws

The `Monad` type class comes equipped with three laws, called the _monad laws_. These tell us what we can expect from sensible implementations of the `Monad` type class.

It is simplest to explain these laws using do notation.

### Identity Laws

The _right-identity_ law is the simplest of the three laws. It tells us that we can eliminate a call to `pure` if it is the last expression in a do notation block:

```hs
do
  x <- expr
  pure x
```

The right-identity law says that this is equivalent to just `expr`.

The _left-identity_ law states that we can eliminate a call to `pure` if it is the first expression in a do notation block:

```hs
do
  x <- pure y
  next
```

This code is equivalent to `next`, after the name `x` has been replaced with the expression `y`.

The last law is the _associativity law_. It tells us how to deal with nested do notation blocks. It states that the following piece of code:

```hs
c1 = do
  y <- do
    x <- m1
    m2
  m3
```

is equivalent to this code:

```hs
c2 = do
  x <- m1
  y <- m2
  m3
```

Each of these computations involves three monadic expression `m1`, `m2` and `m3`. In each case, the result of `m1` is eventually bound to the name `x`, and the result of `m2` is bound to the name `y`.

In `c1`, the two expressions `m1` and `m2` are grouped into their own do notation block.

In `c2`, all three expressions `m1`, `m2` and `m3` appear in the same do notation block.

The associativity law tells us that it is safe to simplify nested do notation blocks in this way.

_Note_ that by the definition of how do notation gets desugared into calls to `bind`, both of `c1` and `c2` are also equivalent to this code:

```hs
c3 = do
  x <- m1
  do
    y <- m2
    m3
```

## Folding With Monads

As an example of working with monads abstractly, this section will present a function which works with any type constructor in the `Monad` type class. This should serve to solidify the intuition that monadic code corresponds to programming "in a larger language" with side-effects, and also illustrate the generality which programming with monads brings.

The function we will write is called `foldM`. It generalizes the `foldl` function that we met earlier to a monadic context. Here is its type signature:

```hs
foldM :: forall m a b. Monad m => (a -> b -> m a) -> a -> List b -> m a
foldl :: forall   a b.            (a -> b ->   a) -> a -> List b ->   a
```

Notice that this is the same as the type of `foldl`, except for the appearance of the monad `m`.

Intuitively, `foldM` performs a fold over a list in some context supporting some set of side-effects.

For example, if we picked `m` to be `Maybe`, then our fold would be allowed to fail by returning `Nothing` at any stage - every step returns an optional result, and the result of the fold is therefore also optional.

If we picked `m` to be the `Array` type constructor, then every step of the fold would be allowed to return zero or more results, and the fold would proceed to the next step independently for each result. At the end, the set of results would consist of all folds over all possible paths. This corresponds to a traversal of a graph!

To write `foldM`, we can simply break the input list into cases.

If the list is empty, then to produce the result of type `a`, we only have one option: we have to return the second argument:

```hs
foldM _ a Nil = pure a
```

Note that we have to use `pure` to lift `a` into the monad `m`.

What if the list is non-empty? In that case, we have a value of type `a`, a value of type `b`, and a function of type `a -> b -> m a`. If we apply the function, we obtain a monadic result of type `m a`. We can bind the result of this computation with a backwards arrow `<-`.

It only remains to recurse on the tail of the list. The implementation is simple:

```hs
foldM f a (b : bs) = do
  a' <- f a b
  foldM f a' bs
```

Note that this implementation is almost identical to that of `foldl` on lists, with the exception of do notation.

We can define and test this function in PSCi. Here is an example - suppose we defined a "safe division" function on integers, which tested for division by zero and used the `Maybe` type constructor to indicate failure:

```hs
{{#include ../exercises/chapter8/test/Examples.purs:safeDivide}}
```

Then we can use `foldM` to express iterated safe division:

```text
> import Test.Examples
> import Data.List (fromFoldable)

> foldM safeDivide 100 (fromFoldable [5, 2, 2])
(Just 5)

> foldM safeDivide 100 (fromFoldable [2, 0, 4])
Nothing
```

The `foldM safeDivide` function returns `Nothing` if a division by zero was attempted at any point. Otherwise it returns the result of repeatedly dividing the accumulator, wrapped in the `Just` constructor.

## Monads and Applicatives

Every instance of the `Monad` type class is also an instance of the `Apply` type class, by virtue of the superclass relationship between the two classes.

However, there is also an implementation of the `Apply` type class which comes "for free" for any instance of `Monad`, given by the `ap` function:

```hs
ap :: forall m a b. Monad m => m (a -> b) -> m a -> m b
ap mf ma = do
  f <- mf
  a <- ma
  pure (f a)
```

If `m` is a law-abiding member of the `Monad` type class, then there is a valid `Apply` instance for `m` given by `ap`.

The interested reader can check that `ap` agrees with `apply` for the monads we have already encountered: `Array`, `Maybe` and `Either e`.

If every monad is also an applicative functor, then we should be able to apply our intuition for applicative functors to every monad. In particular, we can reasonably expect a monad to correspond, in some sense, to programming "in a larger language" augmented with some set of additional side-effects. We should be able to lift functions of arbitrary arities, using `map` and `apply`, into this new language.

But monads allow us to do more than we could do with just applicative functors, and the key difference is highlighted by the syntax of do notation. Consider the `userCity` example again, in which we looked for a user's city in an XML document which encoded their user profile:

```hs
userCity :: XML -> Maybe XML
userCity root = do
  prof <- child root "profile"
  addr <- child prof "address"
  city <- child addr "city"
  pure city
```

Do notation allows the second computation to depend on the result `prof` of the first, and the third computation to depend on the result `addr` of the second, and so on. This dependence on previous values is not possible using only the interface of the `Applicative` type class.

Try writing `userCity` using only `pure` and `apply`: you will see that it is impossible. Applicative functors only allow us to lift function arguments which are independent of each other, but monads allow us to write computations which involve more interesting data dependencies.

In the last chapter, we saw that the `Applicative` type class can be used to express parallelism. This was precisely because the function arguments being lifted were independent of one another. Since the `Monad` type class allows computations to depend on the results of previous computations, the same does not apply - a monad has to combine its side-effects in sequence.

## Exercises

 1. (Easy) Write a function `third` which returns the third element of an array with three or more elements. Your function should return an appropriate `Maybe` type. _Hint:_ Look up the types of the `head` and `tail` functions from the `Data.Array` module in the `arrays` package. Use do notation with the `Maybe` monad to combine these functions.
 1. (Medium) Write a function `possibleSums` which uses `foldM` to determine all possible totals that could be made using a set of coins. The coins will be specified as an array which contains the value of each coin. Your function should have the following result:

     ```text
     > possibleSums []
     [0]

     > possibleSums [1, 2, 10]
     [0,1,2,3,10,11,12,13]
     ```

     _Hint_: This function can be written as a one-liner using `foldM`. You might want to use the `nub` and `sort` functions to remove duplicates and sort the result respectively.
 1. (Medium) Confirm that the `ap` function and the `apply` operator agree for the `Maybe` monad. _Note:_ There are no tests for this exercise.
 1. (Medium) Verify that the monad laws hold for the `Monad` instance for the `Maybe` type, as defined in the `maybe` package. _Note:_ There are no tests for this exercise.
 1. (Medium) Write a function `filterM` which generalizes the `filter` function on lists. Your function should have the following type signature:

     ```hs
     filterM :: forall m a. Monad m => (a -> m Boolean) -> List a -> m (List a)
     ```

 1. (Difficult) Every monad has a default `Functor` instance given by:

     ```hs
     map f a = do
       x <- a
       pure (f x)
     ```

     Use the monad laws to prove that for any monad, the following holds:

     ```hs
     lift2 f (pure a) (pure b) = pure (f a b)
     ```

     where the `Apply` instance uses the `ap` function defined above. Recall that `lift2` was defined as follows:

     ```hs
     lift2 :: forall f a b c. Apply f => (a -> b -> c) -> f a -> f b -> f c
     lift2 f a b = f <$> a <*> b
     ```

    _Note:_ There are no tests for this exercise.

## Native Effects

We will now look at one particular monad which is of central importance in PureScript - the `Effect` monad.

The `Effect` monad is defined in the `Effect` module. It is used to manage so-called _native_ side-effects. If you are familiar with Haskell, it is the equivalent of the `IO` monad.

What are native side-effects? They are the side-effects which distinguish JavaScript expressions from idiomatic PureScript expressions, which typically are free from side-effects. Some examples of native effects are:

- Console IO
- Random number generation
- Exceptions
- Reading/writing mutable state

And in the browser:

- DOM manipulation
- XMLHttpRequest / AJAX calls
- Interacting with a websocket
- Writing/reading to/from local storage

We have already seen plenty of examples of "non-native" side-effects:

- Optional values, as represented by the `Maybe` data type
- Errors, as represented by the `Either` data type
- Multi-functions, as represented by arrays or lists

Note that the distinction is subtle. It is true, for example, that an error message is a possible side-effect of a JavaScript expression, in the form of an exception. In that sense, exceptions do represent native side-effects, and it is possible to represent them using `Effect`. However, error messages implemented using `Either` are not a side-effect of the JavaScript runtime, and so it is not appropriate to implement error messages in that style using `Effect`. So it is not the effect itself which is native, but rather how it is implemented at runtime.

## Side-Effects and Purity

In a pure language like PureScript, one question which presents itself is: without side-effects, how can one write useful real-world code?

The answer is that PureScript does not aim to eliminate side-effects. It aims to represent side-effects in such a way that pure computations can be distinguished from computations with side-effects in the type system. In this sense, the language is still pure.

Values with side-effects have different types from pure values. As such, it is not possible to pass a side-effecting argument to a function, for example, and have side-effects performed unexpectedly.

The only way in which side-effects managed by the `Effect` monad will be presented is to run a computation of type `Effect a` from JavaScript.

The Spago build tool (and other tools) provide a shortcut, by generating additional JavaScript to invoke the `main` computation when the application starts. `main` is required to be a computation in the `Effect` monad.

## The Effect Monad

The `Effect` monad provides a well-typed API for computations with side-effects, while at the same time generating efficient JavaScript.

Let's take a closer look at the return type of the familiar `log` function. `Effect` indicates that this function produces a native effect, console IO in this case.
`Unit` indicates that no _meaningful_ data is returned. You can think of `Unit` as being analogous to the `void` keyword in other languages, such as C, Java, etc.

```hs
log :: String -> Effect Unit
```

> _Aside:_ You may encounter IDE suggestions for the more general (and more elaborately typed) `log` function from `Effect.Class.Console`. This is interchangeable with the one from `Effect.Console` when dealing with the basic `Effect` monad. Reasons for the more general version will become clearer after reading about "Monad Transformers" in the "Monadic Adventures" chapter. For the curious (and impatient), this works because there's a `MonadEffect` instance for `Effect`.
>
> ```hs
> log :: forall m. MonadEffect m => String -> m Unit
> ```

Now let's consider an `Effect` that returns meaningful data. The `random` function from `Effect.Random` produces a random `Number`.

```hs
random :: Effect Number
```

Here's a full example program (found in `test/Random.purs` of this chapter's exercises folder).

```hs
{{#include ../exercises/chapter8/test/Random.purs}}
```

Because `Effect` is a monad, we use do notation to _unwrap_ the data it contains before passing this data on to the effectful `logShow` function. As a refresher, here's the equivalent code written using the `bind` operator:

```hs
main :: Effect Unit
main = random >>= logShow
```

Try running this yourself with:

```shell
spago run --main Test.Random
```

You should see a randomly chosen number between `0.0` and `1.0` printed to the console.

> _Aside:_ `spago run` defaults to searching in the `Main` module for a `main` function. You may also specify an alternate module as an entry point with the `--main` flag, as is done in the above example. Just be sure that this alternate module also contains a `main` function.

Note that it's also possible to generate "random" (technically pseudorandom) data without resorting to impure effectful code. We'll cover these techniques in the "Generative Testing" chapter.

As mentioned previously, the `Effect` monad is of central importance to PureScript. The reason why it's central is because it is the conventional way to interoperate with PureScript's `Foreign Function Interface`, which provides the mechanism to execute a program and perform side effects. While it's desireable to avoid using the `Foreign Function Interface`, it's fairly critical to understand how it works and how to use it, so I recommend reading that chapter before doing any serious PureScript work. That said, the `Effect` monad is fairly simple. It has a few helper functions, but aside from that it doesn't do much except encapsulate side effects.

## Exceptions

Let's examine a function from the `node-fs` package that involves two _native_ side effects: reading mutable state, and exceptions:

```hs
readTextFile :: Encoding -> String -> Effect String
```

If we attempt to read a file that does not exist:

```hs
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)

main :: Effect Unit
main = do
  lines <- readTextFile UTF8 "iDoNotExist.md"
  log lines
```

We encounter the following exception:

```text
    throw err;
    ^
Error: ENOENT: no such file or directory, open 'iDoNotExist.md'
...
  errno: -2,
  syscall: 'open',
  code: 'ENOENT',
  path: 'iDoNotExist.md'
```

To manage this exception gracefully, we can wrap the potentially problematic code in `try` to handle either outcome:

```hs
main :: Effect Unit
main = do
  result <- try $ readTextFile UTF8 "iDoNotExist.md"
  case result of
    Right lines -> log $ "Contents: \n" <> lines
    Left  error -> log $ "Couldn't open file. Error was: " <> message error
```

`try` runs an `Effect` and returns eventual exceptions as a `Left` value. If the computation succeeds, the result gets wrapped in a `Right`:

```hs
try :: forall a. Effect a -> Effect (Either Error a)
```

We can also generate our own exceptions. Here is an alternative implementation of `Data.List.head` which throws an exception if the list is empty, rather than returning a `Maybe` value of `Nothing`.

```hs
exceptionHead :: List Int -> Effect Int
exceptionHead l = case l of
  x : _ -> pure x
  Nil -> throwException $ error "empty list"
```

Note that the `exceptionHead` function is a somewhat impractical example, as it is best to avoid generating exceptions in PureScript code and instead use non-native effects such as `Either` and `Maybe` to manage errors and missing values.

## Mutable State

There is another effect defined in the core libraries: the `ST` effect.

The `ST` effect is used to manipulate mutable state. As pure functional programmers, we know that shared mutable state can be problematic. However, the `ST` effect uses the type system to restrict sharing in such a way that only safe _local_ mutation is allowed.

The `ST` effect is defined in the `Control.Monad.ST` module. To see how it works, we need to look at the types of its actions:

```hs
new :: forall a r. a -> ST r (STRef r a)

read :: forall a r. STRef r a -> ST r a

write :: forall a r. a -> STRef r a -> ST r a

modify :: forall r a. (a -> a) -> STRef r a -> ST r a
```

`new` is used to create a new mutable reference cell of type `STRef r a`, which can be read using the `read` action, and modified using the `write` and `modify` actions. The type `a` is the type of the value stored in the cell, and the type `r` is used to indicate a _memory region_ (or _heap_) in the type system.

Here is an example. Suppose we want to simulate the movement of a particle falling under gravity by iterating a simple update function over a large number of small time steps.

We can do this by creating a mutable reference cell to hold the position and velocity of the particle, and then using a `for` loop to update the value stored in that cell:

```hs
import Prelude

import Control.Monad.ST.Ref (modify, new, read)
import Control.Monad.ST (ST, for, run)

simulate :: forall r. Number -> Number -> Int -> ST r Number
simulate x0 v0 time = do
  ref <- new { x: x0, v: v0 }
  for 0 (time * 1000) \_ ->
    modify
      ( \o ->
          { v: o.v - 9.81 * 0.001
          , x: o.x + o.v * 0.001
          }
      )
      ref
  final <- read ref
  pure final.x
```

At the end of the computation, we read the final value of the reference cell, and return the position of the particle.

Note that even though this function uses mutable state, it is still a pure function, so long as the reference cell `ref` is not allowed to be used by other parts of the program. We will see that this is exactly what the `ST` effect disallows.

To run a computation with the `ST` effect, we have to use the `run` function:

```hs
run :: forall a. (forall r. ST r a) -> a
```

The thing to notice here is that the region type `r` is quantified _inside the parentheses_ on the left of the function arrow. That means that whatever action we pass to `run` has to work with _any region_ `r` whatsoever.

However, once a reference cell has been created by `new`, its region type is already fixed, so it would be a type error to try to use the reference cell outside the code delimited by `run`.  This is what allows `run` to safely remove the `ST` effect, and turn `simulate` into a pure function!

```hs
simulate' :: Number -> Number -> Int -> Number
simulate' x0 v0 time = run (simulate x0 v0 time)
```

You can even try running this function in PSCi:

```text
> import Main

> simulate' 100.0 0.0 0
100.00

> simulate' 100.0 0.0 1
95.10

> simulate' 100.0 0.0 2
80.39

> simulate' 100.0 0.0 3
55.87

> simulate' 100.0 0.0 4
21.54
```

In fact, if we inline the definition of `simulate` at the call to `run`, as follows:

```hs
simulate :: Number -> Number -> Int -> Number
simulate x0 v0 time =
  run do
    ref <- new { x: x0, v: v0 }
    for 0 (time * 1000) \_ ->
      modify
        ( \o ->
            { v: o.v - 9.81 * 0.001
            , x: o.x + o.v * 0.001
            }
        )
        ref
    final <- read ref
    pure final.x
```

then the compiler will notice that the reference cell is not allowed to escape its scope, and can safely turn `ref` into a `var`. Here is the generated JavaScript for `simulate` inlined with `run`:

```javascript
var simulate = function (x0) {
  return function (v0) {
    return function (time) {
      return (function __do() {

        var ref = { value: { x: x0, v: v0 } };

        Control_Monad_ST_Internal["for"](0)(time * 1000 | 0)(function (v) {
          return Control_Monad_ST_Internal.modify(function (o) {
            return {
              v: o.v - 9.81 * 1.0e-3,
              x: o.x + o.v * 1.0e-3
            };
          })(ref);
        })();

        return ref.value.x;

      })();
    };
  };
};
```

Note that this resulting JavaScript is not as optimal as it could be. See [this issue](https://github.com/purescript-contrib/purescript-book/issues/121) for more details. The above snippet should be updated once that issue is resolved.

For comparison, this is the generated JavaScript of the non-inlined form:

```js
var simulate = function (x0) {
  return function (v0) {
    return function (time) {
      return function __do() {

        var ref = Control_Monad_ST_Internal["new"]({ x: x0, v: v0 })();

        Control_Monad_ST_Internal["for"](0)(time * 1000 | 0)(function (v) {
          return Control_Monad_ST_Internal.modify(function (o) {
            return {
              v: o.v - 9.81 * 1.0e-3,
              x: o.x + o.v * 1.0e-3
            };
          })(ref);
        })();

        var $$final = Control_Monad_ST_Internal.read(ref)();
        return $$final.x;
      };
    };
  };
};
```

The `ST` effect is a good way to generate short JavaScript when working with locally-scoped mutable state, especially when used together with actions like `for`, `foreach`, and `while` which generate efficient loops.

## Exercises

1. (Medium) Rewrite the `safeDivide` function as `exceptionDivide` and throw an exception using `throwException` with the message `"div zero"` if the denominator is zero.
1. (Medium) Write a function `estimatePi :: Int -> Number` that uses `n` terms of the [Gregory Series](https://mathworld.wolfram.com/GregorySeries.html) to calculate an approximation of `pi`. _Hints:_ You can pattern your answer like the definition of `simulate` above. You might need to convert an `Int` into a `Number` using `toNumber :: Int -> Number` from `Data.Int`.
1. (Medium) Write a function `fibonacci :: Int -> Int` to compute the `n`th Fibonacci number, using `ST` to track the values of the previous two Fibonacci numbers. Using PSCi, compare the speed of your new `ST`-based implementation against the recursive implementation (`fib`) from Chapter 4.

## DOM Effects

In the final sections of this chapter, we will apply what we have learned about effects in the `Effect` monad to the problem of working with the DOM.

There are a number of PureScript packages for working directly with the DOM, or with open-source DOM libraries. For example:

- [`web-dom`](https://github.com/purescript-web/purescript-web-dom) provides type definitions and low level interface implementations for the W3C DOM spec.
- [`web-html`](https://github.com/purescript-web/purescript-web-html) provides type definitions and low level interface implementations for the W3C HTML5 spec.
- [`jquery`](https://github.com/paf31/purescript-jquery) is a set of bindings to the [jQuery](http://jquery.org) library.

There are also PureScript libraries which build abstractions on top of these libraries, such as

- [`thermite`](https://github.com/paf31/purescript-thermite), which builds on [`react`](https://github.com/purescript-contrib/purescript-react)
- [`react-basic-hooks`](https://github.com/megamaddu/purescript-react-basic-hooks), which builds on [`react-basic`](https://github.com/lumihq/purescript-react-basic)
- [`halogen`](https://github.com/purescript-halogen/purescript-halogen) which provides a type-safe set of abstractions on top of a custom virtual DOM library.

In this chapter, we will use the `react-basic-hooks` library to add a user interface to our address book application, but the interested reader is encouraged to explore alternative approaches.

## An Address Book User Interface

Using the `react-basic-hooks` library, we will define our application as a React _component_. React components describe HTML elements in code as pure data structures, which are then efficiently rendered to the DOM. In addition, components can respond to events like button clicks. The `react-basic-hooks` library uses the `Effect` monad to describe how to handle these events.

A full tutorial for the React library is well beyond the scope of this chapter, but the reader is encouraged to consult its documentation where needed. For our purposes, React will provide a practical example of the `Effect` monad.

We are going to build a form which will allow a user to add a new entry into our address book. The form will contain text boxes for the various fields (first name, last name, city, state, etc.), and an area in which validation errors will be displayed. As the user types text into the text boxes, the validation errors will be updated.

To keep things simple, the form will have a fixed shape: the different phone number types (home, cell, work, other) will be expanded into separate text boxes.

You can launch the web app from the `exercises/chapter8` directory with the following commands:

```shell
$ npm install
$ npx spago build
$ npx parcel src/index.html --open
```

If development tools such as `spago` and `parcel` are installed globally, then the `npx` prefix may be omitted. You have likely already installed `spago` globally with `npm i -g spago`, and the same can be done for `parcel`.

`parcel` should launch a browser window with our "Address Book" app. If you keep the `parcel` terminal open, and rebuild with `spago` in another terminal, the page should automatically refresh with your latest edits. You can also configure automatic rebuilds (and therefore automatic page refresh) on file-save if you're using an [editor](https://github.com/purescript/documentation/blob/master/ecosystem/Editor-and-tool-support.md#editors) that supports [`purs ide`](https://github.com/purescript/purescript/tree/master/psc-ide) or are running [`pscid`](https://github.com/kRITZCREEK/pscid).

In this Address Book app, you should be able to enter some values into the form fields and see the validation errors printed onto the page.

Let's explore how it works.

The `src/index.html` file is minimal:

```html
{{#include ../exercises/chapter8/src/index.html}}
```

The `<script` line includes the JavaScript entry point, `index.js`, which contains this single line:

```js
{{#include ../exercises/chapter8/src/index.js}}
```

It calls our generated JavaScript equivalent of the `main` function of `module Main` (`src/main.purs`). Recall that `spago build` puts all generated JavaScript in the `output` directory.

The `main` function uses the DOM and HTML APIs to render our address book component within the `container` element we defined in `index.html`:

```hs
{{#include ../exercises/chapter8/src/Main.purs:main}}
```

Note that these three lines:

```hs
w <- window
doc <- document w
ctr <- getElementById "container" $ toNonElementParentNode doc
```

Can be consolidated to:

```hs
doc <- document =<< window
ctr <- getElementById "container" $ toNonElementParentNode doc
```

Or consolidated even further to:

```hs
ctr <- getElementById "container" <<< toNonElementParentNode =<< document =<< window
-- or, equivalently:
ctr <- window >>= document >>= toNonElementParentNode >>> getElementById "container"
```

It is a matter of personal preference whether the intermediate `w` and `doc` variables aid in readability.

Let's dig into our AddressBook `reactComponent`. We'll start with a simplified component, and then build up to the actual code in `Main.purs`.

Take a look at this minimal component. Feel free to substitute the full component with this one to see it run:

```hs
mkAddressBookApp :: Effect (ReactComponent {})
mkAddressBookApp =
  reactComponent
    "AddressBookApp"
    (\props -> pure $ D.text "Hi! I'm an address book")
```

`reactComponent` has this intimidating signature:

```hs
reactComponent ::
  forall hooks props.
  Lacks "children" props =>
  Lacks "key" props =>
  Lacks "ref" props =>
  String ->
  ({ | props } -> Render Unit hooks JSX) ->
  Effect (ReactComponent { | props })
```

The important points to note are the arguments after all the type class constraints. It takes a `String` (an arbitrary component name), a function that describes how to convert `props` into rendered `JSX`, and returns our `ReactComponent` wrapped in an `Effect`.

The props-to-JSX function is simply:

```hs
\props -> pure $ D.text "Hi! I'm an address book"
```

`props` are ignored, `D.text` returns `JSX`, and `pure` lifts to rendered JSX. Now `component` has everything it needs to produce the `ReactComponent`.

Next we'll examine some of the additional complexities of the full Address Book component.

These are the first few lines of our full component:

```hs
mkAddressBookApp :: Effect (ReactComponent {})
mkAddressBookApp = do
  reactComponent "AddressBookApp" \props -> R.do
    Tuple person setPerson <- useState examplePerson
```

We track `person` as a piece of state with the `useState` hook.

```hs
Tuple person setPerson <- useState examplePerson
```

Note that you are free to break-up component state into multiple pieces of state with multiple calls to `useState`. For example, we could rewrite this app to use a separate piece of state for each record field of `Person`, but that happens to result in a slightly less convenient architecture in this case.

In other examples, you may encounter the `/\` infix operator for `Tuple`. This is equivalent to the above line:

```hs
firstName /\ setFirstName <- useState p.firstName
```

`useState` takes a default initial value and returns the current value and a way to update the value. We can check the type of `useState` to gain more insight of the types `person` and `setPerson`:

```hs
useState ::
  forall state.
  state ->
  Hook (UseState state) (Tuple state ((state -> state) -> Effect Unit))
```

We can strip the `Hook (UseState state)` wrapper off of the return value because `useState` is called within an `R.do` block. We'll elaborate on `R.do` later.

So now we can observe the following signatures:

```hs
person :: state
setPerson :: (state -> state) -> Effect Unit
```

The specific type of `state` is determined by our initial default value. `Person` `Record` in this case because that is the type of `examplePerson`.

`person` is how we access the current state at each rerender.

`setPerson` is how we update the state. We simply provide a function that describes how to transform the current state to the new state. The record update syntax is perfect for this when the type of `state` happens to be a `Record`, for example:

```hs
setPerson (\currentPerson -> currentPerson {firstName = "NewName"})

```

or as shorthand:

```hs
setPerson _ {firstName = "NewName"}
```

Non-`Record` states can also follow this update pattern. See [this guide](https://github.com/megamaddu/purescript-react-basic-hooks/pull/24#issuecomment-620300541) for more details on best practices.

Recall that `useState` is used within an `R.do` block. `R.do` is a special react hooks variant of `do`. The `R.` prefix "qualifies" this as coming from `React.Basic.Hooks`, and means we use their hooks-compatible version of `bind` in the `R.do` block. This is known as a "qualified do". It lets us ignore the `Hook (UseState state)` wrapping and bind the inner `Tuple` of values to variables.

Another possible state management strategy is with `useReducer`, but that is outside the scope of this chapter.

Rendering `JSX` occurs here:

```hs
pure
  $ D.div
      { className: "container"
      , children:
          renderValidationErrors errors
            <> [ D.div
                  { className: "row"
                  , children:
                      [ D.form_
                          $ [ D.h3_ [ D.text "Basic Information" ]
                            , formField "First Name" "First Name" person.firstName \s ->
                                setPerson _ { firstName = s }
                            , formField "Last Name" "Last Name" person.lastName \s ->
                                setPerson _ { lastName = s }
                            , D.h3_ [ D.text "Address" ]
                            , formField "Street" "Street" person.homeAddress.street \s ->
                                setPerson _ { homeAddress { street = s } }
                            , formField "City" "City" person.homeAddress.city \s ->
                                setPerson _ { homeAddress { city = s } }
                            , formField "State" "State" person.homeAddress.state \s ->
                                setPerson _ { homeAddress { state = s } }
                            , D.h3_ [ D.text "Contact Information" ]
                            ]
                          <> renderPhoneNumbers
                      ]
                  }
              ]
      }
```

Here we produce `JSX` which represents the intended state of the DOM. This JSX is typically created by applying functions corresponding to HTML tags (e.g. `div`, `form`, `h3`, `li`, `ul`, `label`, `input`) which create single HTML elements. These HTML elements are actually React components themselves, converted to JSX. There are usually three variants of each of these functions:

- `div_`: Accepts an array of child elements. Uses default attributes.
- `div`: Accepts a `Record` of attributes. An array of child elements may be passed to the `children` field of this record.
- `div'`: Same as `div`, but returns the `ReactComponent` before conversion to `JSX`.

To display validation errors (if any) at the top of our form, we create a `renderValidationErrors` helper function that turns the `Errors` structure into an array of JSX. This array is prepended to the rest of our form.

```hs
{{#include ../exercises/chapter8/src/Main.purs:renderValidationErrors}}
```

Note that since we are simply manipulating regular data structures here, we can use functions like `map` to build up more interesting elements:

```hs
children: [ D.ul_ (map renderError xs)]
```

We use the `className` property to define classes for CSS styling. We're using the [Bootstrap](https://getbootstrap.com/) `stylesheet` for this project, which is imported in `index.html`. For example, we want items in our form arranged as `row`s, and validation errors to be emphasized with `alert-danger` styling:

```hs
className: "alert alert-danger row"
```

A second helper function is `formField`, which creates a text input for a single form field:

```hs
{{#include ../exercises/chapter8/src/Main.purs:formField}}
```

Putting the `input` and display `text` in a `label` aids in accessibility for screen readers.

The `onChange` attribute allows us to describe how to respond to user input. We use the `handler` function, which has the following type:

```hs
handler :: forall a. EventFn SyntheticEvent a -> (a -> Effect Unit) -> EventHandler
```

For the first argument to `handler` we use `targetValue`, which provides the value of the text within the HTML `input` element. It matches the signature expected by `handler` where the type variable `a` in this case is `Maybe String`:

```hs
targetValue :: EventFn SyntheticEvent (Maybe String)
```

In JavaScript, the `input` element's `onChange` event is actually accompanied by a `String` value, but since strings in JavaScript can be null, `Maybe` is used for safety.

The second argument to `handler`, `(a -> Effect Unit)`, must therefore have this signature:

```hs
Maybe String -> Effect Unit
```

It is a function that describes how to convert this `Maybe String` value into our desired effect. We define a custom `handleValue` function for this purpose and pass it to `handler` as follows:

```hs
onChange:
  let
    handleValue :: Maybe String -> Effect Unit
    handleValue (Just v) = setValue v
    handleValue Nothing  = pure unit
  in
    handler targetValue handleValue
```

`setValue` is the function we provided to each `formField` call that takes a string and makes the appropriate record-update call to the `setPerson` hook.

Note that `handleValue` can be substituted as:

```hs
onChange: handler targetValue $ traverse_ setValue
```

Feel free to investigate the definition of `traverse_` to see how both forms are indeed equivalent.

That covers the basics of our component implementation. However, you should read the source accompanying this chapter in order to get a full understanding of the way the component works.

Obviously, this user interface can be improved in a number of ways. The exercises will explore some ways in which we can make the application more usable.

## Exercises

Modify `src/Main.purs` in the following exercises. There are no unit tests for these exercises.

1. (Easy) Modify the application to include a work phone number text box.
1. (Medium) Right now the application shows validation errors collected in a single "pink-alert" background.  Modify to give each validation error its own pink-alert background by separating them  with blank lines.

    _Hint_: Instead of using a `ul` element to show the validation errors in a list, modify the code to create one `div` with the `alert` and `alert-danger` styles for each error.
1. (Difficult, Extended) One problem with this user interface is that the validation errors are not displayed next to the form fields they originated from. Modify the code to fix this problem.

    _Hint_: the error type returned by the validator should be extended to indicate which field caused the error. You might want to use the following modified `Errors` type:

    ```hs
    data Field = FirstNameField
               | LastNameField
               | StreetField
               | CityField
               | StateField
               | PhoneField PhoneType

    data ValidationError = ValidationError String Field

    type Errors = Array ValidationError
    ```

    You will need to write a function which extracts the validation error for a particular `Field` from the `Errors` structure.

## Conclusion

This chapter has covered a lot of ideas about handling side-effects in PureScript:

- We met the `Monad` type class, and its connection to do notation.
- We introduced the monad laws, and saw how they allow us to transform code written using do notation.
- We saw how monads can be used abstractly, to write code which works with different side-effects.
- We saw how monads are examples of applicative functors, how both allow us to compute with side-effects, and the differences between the two approaches.
- The concept of native effects was defined, and we met the `Effect` monad, which is used to handle native side-effects.
- We used the `Effect` monad to handle a variety of effects: random number generation, exceptions, console IO, mutable state, and DOM manipulation using React.

The `Effect` monad is a fundamental tool in real-world PureScript code. It will be used in the rest of the book to handle side-effects in a number of other use-cases.
