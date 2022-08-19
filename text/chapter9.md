# Asynchronous Effects

## Chapter Goals

This chapter focuses on the `Aff` monad, which is similar to the `Effect` monad, but represents _asynchronous_ side-effects. We'll demonstrate examples of asynchronously interacting with the filesystem and making HTTP requests. We'll also cover how to manage sequential and parallel execution of asynchronous effects.

## Project Setup

New PureScript libraries introduced in this chapter are:

- `aff` - defines the `Aff` monad.
- `node-fs-aff` - asynchronous filesystem operations with `Aff`.
- `affjax` - HTTP requests with AJAX and `Aff`.
- `parallel` - parallel execution of `Aff`.

When running outside of the browser (such as in our Node.js environment), the `affjax` library requires the `xhr2` NPM module, which is listed as dependency in the `package.json` of this chapter. Install that by running:

```shell
$ npm install
```

## Asynchronous JavaScript

A convenient way to work with asynchronous code in JavaScript is with [`async` and `await`](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Async_await). See [this article on asynchronous JavaScript](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing) for more background information.

Here is an example of using this technique to copy the contents of one file to another file:

```js
import { promises as fsPromises } from 'fs'

async function copyFile(file1, file2) {
  let data = await fsPromises.readFile(file1, { encoding: 'utf-8' });
  fsPromises.writeFile(file2, data, { encoding: 'utf-8' });
}

copyFile('file1.txt', 'file2.txt')
.catch(e => {
  console.log('There was a problem with copyFile: ' + e.message);
});
```

It is also possible to use callbacks or synchronous functions, but those are less desireable because:

- Callbacks lead to excessive nesting, known as "Callback Hell" or the "Pyramid of Doom".
- Synchronous functions block execution of the other code in your app.

## Asynchronous PureScript

The `Aff` monad in PureScript offers similar ergonomics of JavaScript's `async`/`await` syntax. Here is the same `copyFile` example from before, but rewritten in PureScript using `Aff`:

```hs
{{#include ../exercises/chapter9/test/Copy.purs:copyFile}}
```

It is also possible to re-write the above snippet using callbacks or synchronous functions (for example with `Node.FS.Async` and `Node.FS.Sync` respectively), but those share the same downsides as discussed earlier with JavaScript, and so that coding style is not recommended.

The syntax for working with `Aff` is very similar to working with `Effect`. They are both monads, and can therefore be written with do notation.

For example, if we look at the signature of `readTextFile`, we see that it returns the file contents as a `String` wrapped in `Aff`:

```hs
readTextFile :: Encoding -> FilePath -> Aff String
```

We can "unwrap" the returned string with a bind arrow (`<-`) in do notation:

```hs
my_data <- readTextFile UTF8 file1
```

Then pass it as the string argument to `writeTextFile`:

```hs
writeTextFile :: Encoding -> FilePath -> String -> Aff Unit
```

The only other notable feature unique to `Aff` in the above example is `attempt`, which captures errors or exceptions encountered while running `Aff` code and stores them in an `Either`:

```hs
attempt :: forall a. Aff a -> Aff (Either Error a)
```

You should hopefully be able to draw on your knowledge of concepts from previous chapters and combine this with the new `Aff` patterns learned in the above `copyFile` example to tackle the following exercises:

## Exercises

 1. (Easy) Write a `concatenateFiles` function which concatenates two text files.

 1. (Medium) Write a function `concatenateMany` to concatenate multiple text files, given an array of input file names and an output file name. _Hint_: use `traverse`.

 1. (Medium) Write a function `countCharacters :: FilePath -> Aff (Either Error Int)` that returns the number of characters in a file, or an error if one is encountered.

## Additional Aff Resources

If you haven't already taken a look at the [official Aff guide](https://pursuit.purescript.org/packages/purescript-aff/), skim through that now. It's not a direct prerequisite for completing the remaining exercises in this chapter, but you may find it helpful to lookup some functions on Pursuit.

You're also welcome to consult these supplemental resources too, but again, the exercises in this chapter don't depend on them:

- [Drew's Aff Post](https://blog.drewolson.org/asynchronous-purescript)
- [Additional Aff Explanation and Examples](https://github.com/JordanMartinez/purescript-jordans-reference/tree/latestRelease/21-Hello-World/02-Effect-and-Aff/src/03-Aff)

## A HTTP Client

The `affjax` library offers a convenient way to make asynchronous AJAX HTTP requests with `Aff`. Depending on what environment you are targeting you need to use either the [purescript-affjax-web](https://github.com/purescript-contrib/purescript-affjax-web) or the [purescript-affjax-node](https://github.com/purescript-contrib/purescript-affjax-node) library.
In the rest of this chapter we will be targeting node and thus using `purescript-affjax-node`.
Consult the [Affjax docs](https://pursuit.purescript.org/packages/purescript-affjax) for more usage information. Here is an example that makes HTTP GET requests at a provided URL and returns the response body or an error message:

```hs
{{#include ../exercises/chapter9/test/HTTP.purs:getUrl}}
```

When calling this in the repl, `launchAff_` is required to convert the `Aff` to a repl-compatible `Effect`:

```shell
$ spago repl

> :pa
… import Prelude
… import Effect.Aff (launchAff_)
… import Effect.Class.Console (log)
… import Test.HTTP (getUrl)
…
… launchAff_ do
…   str <- getUrl "https://reqres.in/api/users/1"
…   log str
…
unit
{"data":{"id":1,"email":"george.bluth@reqres.in","first_name":"George","last_name":"Bluth", ...}}
```

## Exercises

1. (Easy) Write a function `writeGet` which makes an HTTP `GET` request to a provided url, and writes the response body to a file.

## Parallel Computations

We've seen how to use the `Aff` monad and do notation to compose asynchronous computations in sequence. It would also be useful to be able to compose asynchronous computations _in parallel_. With `Aff`, we can compute in parallel simply by initiating our two computations one after the other.

The `parallel` package defines a type class `Parallel` for monads like `Aff` which support parallel execution. When we met applicative functors earlier in the book, we observed how applicative functors can be useful for combining parallel computations. In fact, an instance for `Parallel` defines a correspondence between a monad `m` (such as `Aff`) and an applicative functor `f` which can be used to combine computations in parallel:

```hs
class (Monad m, Applicative f) <= Parallel f m | m -> f, f -> m where
  sequential :: forall a. f a -> m a
  parallel :: forall a. m a -> f a
```

The class defines two functions:

- `parallel`, which takes computations in the monad `m` and turns them into computations in the applicative functor `f`, and
- `sequential`, which performs a conversion in the opposite direction.

The `aff` library provides a `Parallel` instance for the `Aff` monad. It uses mutable references to combine `Aff` actions in parallel, by keeping track of which of the two continuations has been called. When both results have been returned, we can compute the final result and pass it to the main continuation.

Because applicative functors support lifting of functions of arbitrary arity, we can perform more computations in parallel by using the applicative combinators. We can also benefit from all of the standard library functions which work with applicative functors, such as `traverse` and `sequence`!

We can also combine parallel computations with sequential portions of code, by using applicative combinators in a do notation block, or vice versa, using `parallel` and `sequential` to change type constructors where appropriate.

To demonstrate the difference between sequential and parallel execution, we'll create an array of 100 10-millisecond delays, then execute those delays with both techniques.
You'll notice in the repl that `seqDelay` is much slower than `parDelay`.
Note that parallel execution is enabled by simply replacing `sequence_` with `parSequence_`.

```hs
{{#include ../exercises/chapter9/test/ParallelDelay.purs:delays}}
```

```shell
$ spago repl

> import Test.ParallelDelay

> seqDelay -- This is slow
unit

> parDelay -- This is fast
unit
```

Here's a more real-world example of making multiple HTTP requests in parallel. We're reusing our `getUrl` function to fetch information from two users in parallel. Note that `parTraverse` (the parallel version of `traverse`) is used in this case. This example would also work fine with `traverse` instead, but it will be slower.

```hs
{{#include ../exercises/chapter9/test/ParallelFetch.purs:fetchPar}}
```

```shell
$ spago repl

> import Test.ParallelFetch

> fetchPar
unit
["{\"data\":{\"id\":1,\"email\":\"george.bluth@reqres.in\", ... }"
,"{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\", ... }"
]
```

A full listing of available parallel functions can be found in the [`parallel` docs on Pursuit](https://pursuit.purescript.org/packages/purescript-parallel/docs/Control.Parallel). The [aff docs section on parallel](https://github.com/purescript-contrib/purescript-aff#parallel-execution) also contains more examples.

## Exercises

1. (Easy) Write a `concatenateManyParallel` function which has the same signature as the earlier `concatenateMany` function, but reads all input files in parallel.

1. (Medium) Write a `getWithTimeout :: Number -> String -> Aff (Maybe String)` function which makes an HTTP `GET` request at the provided URL and returns either:
    - `Nothing`: if the request takes longer than the provided timeout (in milliseconds).
    - The string response: if the request succeeds before the timeout elapses.

1. (Difficult) Write a `recurseFiles` function which takes a "root" file and returns an array of all paths listed in that file (and listed in the listed files too). Read listed files in parallel. Paths are relative to the directory of the file they appear in. _Hint:_ The `node-path` module has some helpful functions for negotiating directories.

For example, if starting from the following `root.txt` file:

```shell
$ cat root.txt
a.txt
b/a.txt
c/a/a.txt

$ cat a.txt
b/b.txt

$ cat b/b.txt
c/a.txt

$ cat b/c/a.txt

$ cat b/a.txt

$ cat c/a/a.txt
```

The expected output is:

```hs
["root.txt","a.txt","b/a.txt","b/b.txt","b/c/a.txt","c/a/a.txt"]
```

## Conclusion

In this chapter we covered asynchronous effects and learned how to:

- Run asynchronous code in the `Aff` monad with the `aff` library.
- Make HTTP requests asynchronously with the `affjax` library.
- Run asynchronous code in parallel with the `parallel` library.
