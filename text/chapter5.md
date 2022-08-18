# Pattern Matching

## Chapter Goals

This chapter will introduce two new concepts: algebraic data types, and pattern matching. We will also briefly cover an interesting feature of the PureScript type system: row polymorphism.

Pattern matching is a common technique in functional programming and allows the developer to write compact functions which express potentially complex ideas, by breaking their implementation down into multiple cases.

Algebraic data types are a feature of the PureScript type system which enable a similar level of expressiveness in the language of types - they are closely related to pattern matching.

The goal of the chapter will be to write a library to describe and manipulate simple vector graphics using algebraic types and pattern matching.

## Project Setup

The source code for this chapter is defined in the file `src/Data/Picture.purs`.

The `Data.Picture` module defines a data type `Shape` for simple shapes, and a type `Picture` for collections of shapes, along with functions for working with those types.

The module imports the `Data.Foldable` module, which provides functions for folding data structures:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:module_picture}}
```

The `Data.Picture` module also imports the `Number` module, but this time using the `as` keyword:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:picture_import_as}}
```

This makes the types and functions in that module available for use, but only by using the _qualified name_, like `Number.max`. This can be useful to avoid overlapping imports, or just to make it clearer which modules certain things are imported from.

_Note_: it is not necessary to use the same module name as the original module for a qualified import. Shorter qualified names like `import Data.Number as N` are possible, and quite common.

## Simple Pattern Matching

Let's begin by looking at an example. Here is a function which computes the greatest common divisor of two integers using pattern matching:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:gcd}}
```

This algorithm is called the Euclidean Algorithm. If you search for its definition online, you will likely find a set of mathematical equations which look a lot like the code above. This is one benefit of pattern matching: it allows you to define code by cases, writing simple, declarative code which looks like a specification of a mathematical function.

A function written using pattern matching works by pairing sets of conditions with their results. Each line is called an _alternative_ or a _case_. The expressions on the left of the equals sign are called _patterns_, and each case consists of one or more patterns, separated by spaces. Cases describe which conditions the arguments must satisfy before the expression on the right of the equals sign should be evaluated and returned. Each case is tried in order, and the first case whose patterns match their inputs determines the return value.

For example, the `gcd` function is evaluated using the following steps:

- The first case is tried: if the second argument is zero, the function returns `n` (the first argument).
- If not, the second case is tried: if the first argument is zero, the function returns `m` (the second argument).
- Otherwise, the function evaluates and returns the expression in the last line.

Note that patterns can bind values to names - each line in the example binds one or both of the names `n` and `m` to the input values. As we learn about different kinds of patterns, we will see that different types of patterns correspond to different ways to choose names from the input arguments.

## Simple Patterns

The example code above demonstrates two types of patterns:

- Integer literals patterns, which match something of type `Int`, only if the value matches exactly.
- Variable patterns, which bind their argument to a name

There are other types of simple patterns:

- `Number`, `String`, `Char` and `Boolean` literals
- Wildcard patterns, indicated with an underscore (`_`), which match any argument, and which do not bind any names.

Here are two more examples which demonstrate using these simple patterns:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:fromString}}

{{#include ../exercises/chapter5/src/ChapterExamples.purs:toString}}
```

Try these functions in PSCi.

## Guards

In the Euclidean algorithm example, we used an `if .. then .. else` expression to switch between the two alternatives when `m > n` and `m <= n`. Another option in this case would be to use a _guard_.

A guard is a boolean-valued expression which must be satisfied in addition to the constraints imposed by the patterns. Here is the Euclidean algorithm rewritten to use a guard:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:gcdV2}}
```

In this case, the third line uses a guard to impose the extra condition that the first argument is strictly larger than the second. The guard in the final line uses the expression `otherwise`, which might seem like a keyword, but is in fact just a regular binding in `Prelude`:

```text
> :type otherwise
Boolean

> otherwise
true
```

As this example demonstrates, guards appear on the left of the equals symbol, separated from the list of patterns by a pipe character (`|`).

## Exercises

1. (Easy) Write the `factorial` function using pattern matching. _Hint_: Consider the two corner cases of zero and non-zero inputs. _Note_: This is a repeat of an example from the previous chapter, but see if you can rewrite it here on your own.
1. (Medium) Write a function `binomial` which finds the coefficient of the x^`k`th term in the polynomial expansion of (1 + x)^`n`. This is the same as the number of ways to choose a subset of `k` elements from a set of `n` elements. Use the formula `n! / k! (n - k)!`, where `!` is the factorial function written earlier. _Hint_: Use pattern matching to handle corner cases. If it takes a long time to complete or crashes with an error about the call stack, try adding more corner cases.
1. (Medium) Write a function `pascal` which uses [_Pascal`s Rule_](https://en.wikipedia.org/wiki/Pascal%27s_rule) for computing the same binomial coefficients as the previous exercise.

## Array Patterns

_Array literal patterns_ provide a way to match arrays of a fixed length. For example, suppose we want to write a function `isEmpty` which identifies empty arrays. We could do this by using an empty array pattern (`[]`) in the first alternative:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:isEmpty}}
```

Here is another function which matches arrays of length five, binding each of its five elements in a different way:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:takeFive}}
```

The first pattern only matches arrays with five elements, whose first and second elements are 0 and 1 respectively. In that case, the function returns the product of the third and fourth elements. In every other case, the function returns zero. For example, in PSCi:

```text
> :paste
… takeFive [0, 1, a, b, _] = a * b
… takeFive _ = 0
… ^D

> takeFive [0, 1, 2, 3, 4]
6

> takeFive [1, 2, 3, 4, 5]
0

> takeFive []
0
```

Array literal patterns allow us to match arrays of a fixed length, but PureScript does _not_ provide any means of matching arrays of an unspecified length, since destructuring immutable arrays in these sorts of ways can lead to poor performance. If you need a data structure which supports this sort of matching, the recommended approach is to use `Data.List`. Other data structures exist which provide improved asymptotic performance for different operations.

## Record Patterns and Row Polymorphism

_Record patterns_ are used to match - you guessed it - records.

Record patterns look just like record literals, but instead of values on the right of the colon, we specify a binder for each field.

For example: this pattern matches any record which contains fields called `first` and `last`, and binds their values to the names `x` and `y` respectively:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:showPerson}}
```

Record patterns provide a good example of an interesting feature of the PureScript type system: _row polymorphism_. Suppose we had defined `showPerson` without a type signature above. What would its inferred type have been? Interestingly, it is not the same as the type we gave:

```text
> showPerson { first: x, last: y } = y <> ", " <> x

> :type showPerson
forall r. { first :: String, last :: String | r } -> String
```

What is the type variable `r` here? Well, if we try `showPerson` in PSCi, we see something interesting:

```text
> showPerson { first: "Phil", last: "Freeman" }
"Freeman, Phil"

> showPerson { first: "Phil", last: "Freeman", location: "Los Angeles" }
"Freeman, Phil"
```

We are able to append additional fields to the record, and the `showPerson` function will still work. As long as the record contains the `first` and `last` fields of type `String`, the function application is well-typed. However, it is _not_ valid to call `showPerson` with too _few_ fields:

```text
> showPerson { first: "Phil" }

Type of expression lacks required label "last"
```

We can read the new type signature of `showPerson` as "takes any record with `first` and `last` fields which are `Strings` _and any other fields_, and returns a `String`". This function is polymorphic in the _row_ `r` of record fields, hence the name _row polymorphism_.  Note that this behavior is different than that of the original `showPerson`. Without the row variable `r`, `showPerson` only accepts records with _exactly_ a `first` and `last` field and no others.

Note that we could have also written

```haskell
> showPerson p = p.last <> ", " <> p.first
```

and PSCi would have inferred the same type.

## Record Puns

Recall that the `showPerson` function matches a record inside its argument, binding the `first` and `last` fields to values named `x` and `y`. We could alternatively just reuse the field names themselves, and simplify this sort of pattern match as follows:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:showPersonV2}}
```

Here, we only specify the names of the fields, and we do not need to specify the names of the values we want to introduce. This is called a _record pun_.

It is also possible to use record puns to _construct_ records. For example, if we have values named `first` and `last` in scope, we can construct a person record using `{ first, last }`:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:unknownPerson}}
```

This may improve readability of code in some circumstances.

## Nested Patterns

Array patterns and record patterns both combine smaller patterns to build larger patterns. For the most part, the examples above have only used simple patterns inside array patterns and record patterns, but it is important to note that patterns can be arbitrarily _nested_, which allows functions to be defined using conditions on potentially complex data types.

For example, this code combines two record patterns:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:livesInLA}}
```

## Named Patterns

Patterns can be _named_ to bring additional names into scope when using nested patterns. Any pattern can be named by using the `@` symbol.

For example, this function sorts two-element arrays, naming the two elements, but also naming the array itself:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:sortPair}}
```

This way, we save ourselves from allocating a new array if the pair is already sorted. Note that if the input array does not contain _exactly_ two elements, then this function simply returns it unchanged, even if it's unsorted.

## Exercises

1. (Easy) Write a function `sameCity` which uses record patterns to test whether two `Person` records belong to the same city.
1. (Medium) What is the most general type of the `sameCity` function, taking into account row polymorphism? What about the `livesInLA` function defined above? _Note_: There is no test for this exercise.
1. (Medium) Write a function `fromSingleton` which uses an array literal pattern to extract the sole member of a singleton array. If the array is not a singleton, your function should return a provided default value. Your function should have type `forall a. a -> Array a -> a`

## Case Expressions

Patterns do not only appear in top-level function declarations. It is possible to use patterns to match on an intermediate value in a computation, using a `case` expression. Case expressions provide a similar type of utility to anonymous functions: it is not always desirable to give a name to a function, and a `case` expression allows us to avoid naming a function just because we want to use a pattern.

Here is an example. This function computes "longest zero suffix" of an array (the longest suffix which sums to zero):

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:lzsImport}}

{{#include ../exercises/chapter5/src/ChapterExamples.purs:lzs}}
```

For example:

```text
> lzs [1, 2, 3, 4]
[]

> lzs [1, -1, -2, 3]
[-1, -2, 3]
```

This function works by case analysis. If the array is empty, our only option is to return an empty array. If the array is non-empty, we first use a `case` expression to split into two cases. If the sum of the array is zero, we return the whole array. If not, we recurse on the tail of the array.

## Pattern Match Failures and Partial Functions

If patterns in a case expression are tried in order, then what happens in the case when none of the patterns in a case alternatives match their inputs? In this case, the case expression will fail at runtime with a _pattern match failure_.

We can see this behavior with a simple example:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:unsafePartialImport}}

{{#include ../exercises/chapter5/src/ChapterExamples.purs:partialFunction}}
```

This function contains only a single case, which only matches a single input, `true`. If we compile this file, and test in PSCi with any other argument, we will see an error at runtime:

```text
> partialFunction false

Failed pattern match
```

Functions which return a value for any combination of inputs are called _total_ functions, and functions which do not are called _partial_.

It is generally considered better to define total functions where possible. If it is known that a function does not return a result for some valid set of inputs, it is usually better to return a value capable of indicating failure, such as type `Maybe a` for some `a`, using `Nothing` when it cannot return a valid result. This way, the presence or absence of a value can be indicated in a type-safe way.

The PureScript compiler will generate an error if it can detect that your function is not total due to an incomplete pattern match. The `unsafePartial` function can be used to silence these errors (if you are sure that your partial function is safe!) If we removed the call to the `unsafePartial` function above, then the compiler would generate the following error:

```text
A case expression could not be determined to cover all inputs.
The following additional cases are required to cover all inputs:

  false
```

This tells us that the value `false` is not matched by any pattern. In general, these warnings might include multiple unmatched cases.

If we also omit the type signature above:

```haskell
partialFunction true = true
```

then PSCi infers a curious type:

```text
> :type partialFunction

Partial => Boolean -> Boolean
```

We will see more types which involve the `=>` symbol later on in the book (they are related to _type classes_), but for now, it suffices to observe that PureScript keeps track of partial functions using the type system, and that we must explicitly tell the type checker when they are safe.

The compiler will also generate a warning in certain cases when it can detect that cases are _redundant_ (that is, a case only matches values which would have been matched by a prior case):

```haskell
redundantCase :: Boolean -> Boolean
redundantCase true = true
redundantCase false = false
redundantCase false = false
```

In this case, the last case is correctly identified as redundant:

```text
A case expression contains unreachable cases:

  false
```

_Note_: PSCi does not show warnings, so to reproduce this example, you will need to save this function as a file and compile it using `spago build`.

## Algebraic Data Types

This section will introduce a feature of the PureScript type system called _Algebraic Data Types_ (or _ADTs_), which are fundamentally related to pattern matching.

However, we'll first consider a motivating example, which will provide the basis of a solution to this chapter's problem of implementing a simple vector graphics library.

Suppose we wanted to define a type to represent some simple shapes: lines, rectangles, circles, text, etc. In an object oriented language, we would probably define an interface or abstract class `Shape`, and one concrete subclass for each type of shape that we wanted to be able to work with.

However, this approach has one major drawback: to work with `Shape`s abstractly, it is necessary to identify all of the operations one might wish to perform, and to define them on the `Shape` interface. It becomes difficult to add new operations without breaking modularity.

Algebraic data types provide a type-safe way to solve this sort of problem, if the set of shapes is known in advance. It is possible to define new operations on `Shape` in a modular way, and still maintain type-safety.

Here is how `Shape` might be represented as an algebraic data type:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:Shape}}

{{#include ../exercises/chapter5/src/Data/Picture.purs:Point}}
```

This declaration defines `Shape` as a sum of different constructors, and for each constructor identifies the data that is included. A `Shape` is either a `Circle` which contains a center `Point` and a radius (a number), or a `Rectangle`, or a `Line`, or `Text`. There are no other ways to construct a value of type `Shape`.

An algebraic data type is introduced using the `data` keyword, followed by the name of the new type and any type arguments. The type's constructors (i.e. its _data constructors_) are defined after the equals symbol, and are separated by pipe characters (`|`). The data carried by an ADT's constructors doesn't have to be restricted to primitive types: constructors can include records, arrays, or even other ADTs.

Let's see another example from PureScript's standard libraries. We saw the `Maybe` type, which is used to define optional values, earlier in the book. Here is its definition from the `maybe` package:

```haskell
data Maybe a = Nothing | Just a
```

This example demonstrates the use of a type parameter `a`. Reading the pipe character as the word "or", its definition almost reads like English: "a value of type `Maybe a` is either `Nothing`, or `Just` a value of type `a`".

Note that we don't use the syntax `forall a.` anywhere in our data definition. `forall` syntax is necessary for functions, but is not used when defining ADTs with `data` or type aliases with `type`.

Data constructors can also be used to define recursive data structures. Here is one more example, defining a data type of singly-linked lists of elements of type `a`:

```haskell
data List a = Nil | Cons a (List a)
```

This example is taken from the `lists` package. Here, the `Nil` constructor represents an empty list, and `Cons` is used to create non-empty lists from a head element and a tail. Notice how the tail is defined using the data type `List a`, making this a recursive data type.

## Using ADTs

It is simple enough to use the constructors of an algebraic data type to construct a value: simply apply them like functions, providing arguments corresponding to the data included with the appropriate constructor.

For example, the `Line` constructor defined above required two `Point`s, so to construct a `Shape` using the `Line` constructor, we have to provide two arguments of type `Point`:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:exampleLine}}
```

So, constructing values of algebraic data types is simple, but how do we use them? This is where the important connection with pattern matching appears: the only way to consume a value of an algebraic data type is to use a pattern to match its constructor.

Let's see an example. Suppose we want to convert a `Shape` into a `String`. We have to use pattern matching to discover which constructor was used to construct the `Shape`. We can do this as follows:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:showShape}}

{{#include ../exercises/chapter5/src/Data/Picture.purs:showPoint}}
```

Each constructor can be used as a pattern, and the arguments to the constructor can themselves be bound using patterns of their own. Consider the first case of `showShape`: if the `Shape` matches the `Circle` constructor, then we bring the arguments of `Circle` (center and radius) into scope using two variable patterns, `c` and `r`. The other cases are similar.

## Exercises

1. (Easy) Write a function `circleAtOrigin` which constructs a `Circle` (of type `Shape`) centered at the origin with radius `10.0`.
1. (Medium) Write a function `doubleScaleAndCenter` which scales the size of a `Shape` by a factor of `2.0` and centers it at the origin.
1. (Medium) Write a function `shapeText` which extracts the text from a `Shape`. It should return `Maybe String`, and use the `Nothing` constructor if the input is not constructed using `Text`.

## Newtypes

There is a special case of algebraic data types, called _newtypes_. Newtypes are introduced using the `newtype` keyword instead of the `data` keyword.

Newtypes must define _exactly one_ constructor, and that constructor must take _exactly one_ argument. That is, a newtype gives a new name to an existing type. In fact, the values of a newtype have the same runtime representation as the underlying type, so there is no runtime performance overhead. They are, however, distinct from the point of view of the type system. This gives an extra layer of type safety.

As an example, we might want to define newtypes as type-level aliases for `Number`, to ascribe units like volts, amps, and ohms:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:electricalUnits}}
```

Then we define functions and values using these types:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:calculateCurrent}}
```

This prevents us from making silly mistakes, such as attempting to calculate the current produced by _two_ lightbulbs _without_ a voltage source.

```haskell
current :: Amp
current = calculateCurrent lightbulb lightbulb
{-
TypesDoNotUnify:
  current = calculateCurrent lightbulb lightbulb
                             ^^^^^^^^^
  Could not match type
    Ohm
  with type
    Volt
-}
```

If we instead just used `Number` without `newtype`, then the compiler can't help us catch this mistake:

```haskell
-- This also compiles, but is not as type safe.
calculateCurrent :: Number -> Number -> Number
calculateCurrent v r = v / r

battery :: Number
battery = 1.5

lightbulb :: Number
lightbulb = 500.0

current :: Number
current = calculateCurrent lightbulb lightbulb -- uncaught mistake
```

Note that while a newtype can only have a single constructor, and the constructor must be of a single value, a newtype _can_ take any number of type variables. For example, the following newtype would be a valid definition (`err` and `a` are the type variables, and the `CouldError` constructor expects a _single_ value of type `Either err a`):

```Haskell
newtype CouldError err a = CouldError (Either err a)
```

Also note that the constructor of a newtype often has the same name as the newtype itself, but this is not a requirement. For example, unique names are also valid:

```haskell
{{#include ../exercises/chapter5/src/ChapterExamples.purs:Coulomb}}
```

In this case, `Coulomb` is the _type constructor_ (of zero arguments) and `MakeCoulomb` is the _data constructor_. These constructors live in different namespaces, even when the names are identical, such as with the `Volt` example. This is true for all ADTs. Note that although the type constructor and data constructor can have different names, in practice it is idiomatic for them to share the same name. This is the case with `Amp` and `Volt` types above.

Another application of newtypes is to attach different _behavior_ to an existing type without changing its representation at runtime. We cover that use case in the next chapter when we discuss _type classes_.

## Exercises

1. (Easy) Define `Watt` as a `newtype` of `Number`. Then define a `calculateWattage` function using this new `Watt` type and the above definitions `Amp` and `Volt`:

```haskell
calculateWattage :: Amp -> Volt -> Watt
```

A wattage in `Watt`s can be calculated as the product of a given current in `Amp`s and a given voltage in `Volt`s.

## A Library for Vector Graphics

Let's use the data types we have defined above to create a simple library for using vector graphics.

Define a type synonym for a `Picture` - just an array of `Shape`s:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:Picture}}
```

For debugging purposes, we'll want to be able to turn a `Picture` into something readable. The `showPicture` function lets us do that:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:showPicture}}
```

Let's try it out. Compile your module with `spago build` and open PSCi with `spago repl`:

```text
$ spago build
$ spago repl

> import Data.Picture

> showPicture [ Line { x: 0.0, y: 0.0 } { x: 1.0, y: 1.0 } ]

["Line [start: (0.0, 0.0), end: (1.0, 1.0)]"]
```

## Computing Bounding Rectangles

The example code for this module contains a function `bounds` which computes the smallest bounding rectangle for a `Picture`.

The `Bounds` type defines a bounding rectangle.

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:Bounds}}
```

`bounds` uses the `foldl` function from `Data.Foldable` to traverse the array of `Shapes` in a `Picture`, and accumulate the smallest bounding rectangle:

```haskell
{{#include ../exercises/chapter5/src/Data/Picture.purs:bounds}}
```

In the base case, we need to find the smallest bounding rectangle of an empty `Picture`, and the empty bounding rectangle defined by `emptyBounds` suffices.

The accumulating function `combine` is defined in a `where` block. `combine` takes a bounding rectangle computed from `foldl`'s recursive call, and the next `Shape` in the array, and uses the `union` function to compute the union of the two bounding rectangles. The `shapeBounds` function computes the bounds of a single shape using pattern matching.

## Exercises

1. (Medium) Extend the vector graphics library with a new operation `area` which computes the area of a `Shape`. For the purpose of this exercise, the area of a line or a piece of text is assumed to be zero.
1. (Difficult) Extend the `Shape` type with a new data constructor `Clipped`, which clips another `Picture` to a rectangle. Extend the `shapeBounds` function to compute the bounds of a clipped picture. Note that this makes `Shape` into a recursive data type.

## Conclusion

In this chapter, we covered pattern matching, a basic but powerful technique from functional programming. We saw how to use simple patterns as well as array and record patterns to match parts of deep data structures.

This chapter also introduced algebraic data types, which are closely related to pattern matching. We saw how algebraic data types allow concise descriptions of data structures, and provide a modular way to extend data types with new operations.

Finally, we covered _row polymorphism_, a powerful type of abstraction which allows many idiomatic JavaScript functions to be given a type.

In the rest of the book, we will use ADTs and pattern matching extensively, so it will pay dividends to become familiar with them now. Try creating your own algebraic data types and writing functions to consume them using pattern matching.
