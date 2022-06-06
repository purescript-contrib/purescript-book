# Getting Started

## Chapter Goals

In this chapter, we'll set up a working PureScript development environment, solve some exercises, and use the tests provided with this book to check our answers. You may also find a [video walkthrough of this chapter](https://www.youtube.com/watch?v=GPjPwb6d-70) helpful if that better suits your learning style.

## Environment Setup

First, work through this [Getting Started Guide](https://github.com/purescript/documentation/blob/master/guides/Getting-Started.md) in the Documentation Repo to setup your environment and learn a few basics about the language. Don't worry if the code in the example solution to the [Project Euler](http://projecteuler.net/problem=1) problem is confusing or contains unfamiliar syntax. We'll cover all of this in great detail in the upcoming chapters.

## Solving Exercises

Now that you've installed the necessary development tools, clone this book's repo.

```sh
git clone https://github.com/purescript-contrib/purescript-book.git
```

The book repo contains PureScript example code and unit tests for the exercises that accompany each chapter. There's some initial setup required to reset the exercise solutions so they are ready to be solved by you. Use the `resetSolutions.sh` script to simplify this process. While you're at it, you should also strip out all the anchor comments with the `removeAnchors.sh` script (these anchors are used for copying code snippets into the book's rendered markdown, and you probably don't need this clutter in your local repo):

```sh
cd purescript-book
./scripts/resetSolutions.sh
./scripts/removeAnchors.sh
git add .
git commit --all --message "Exercises ready to be solved"
```

Now run the tests for this chapter:

```sh
cd exercises/chapter2
spago test
```

You should see the following successful test output:

```sh
→ Suite: Euler - Sum of Multiples
  ✓ Passed: below 10
  ✓ Passed: below 1000

All 2 tests passed! 🎉
```

Note that the `answer` function (found in `src/Euler.purs`) has been modified to find the multiples of 3 and 5 below any integer. The test suite (found in `test/Main.purs`) for this `answer` function is more comprehensive than the test in the earlier getting-started guide. Don't worry about understanding how this test framework code works while reading these early chapters.

The remainder of the book contains lots of exercises. If you write your solutions in the `Test.MySolutions` module (`test/MySolutions.purs`), you can check your work against the provided test suite.

Let's work through this next exercise together in test-driven-development style.

## Exercise

1. (Medium) Write a `diagonal` function to compute the length of the diagonal (or hypotenuse) of a right-angled triangle when given the lengths of the two other sides.

## Solution

We'll start by enabling the tests for this exercise. Move the start of the block-comment down a few lines as shown below. Block comments start with `{-` and end with `-}`:

```hs
{{#include ../exercises/chapter2/test/Main.purs:diagonalTests}}
    {-  Move this block comment starting point to enable more tests
```

If we attempt to run the test now, we'll encounter a compilation error because we have not yet implemented our `diagonal` function.

```sh
$ spago test

Error found:
in module Test.Main
at test/Main.purs:21:27 - 21:35 (line 21, column 27 - line 21, column 35)

  Unknown value diagonal
```

Let's first take a look at what happens with a faulty version of this function. Add the following code to `test/MySolutions.purs`:

```hs
import Data.Number (sqrt)

diagonal w h = sqrt (w * w + h)
```

And check our work by running `spago test`:

```hs
→ Suite: diagonal
  ☠ Failed: 3 4 5 because expected 5.0, got 3.605551275463989
  ☠ Failed: 5 12 13 because expected 13.0, got 6.082762530298219

2 tests failed:
```

Uh-oh, that's not quite right. Let's fix this with the correct application of the Pythagorean formula by changing the function to:

```hs
{{#include ../exercises/chapter2/test/no-peeking/Solutions.purs:diagonal}}
```

Trying `spago test` again now shows all tests are passing:

```hs
→ Suite: Euler - Sum of Multiples
  ✓ Passed: below 10
  ✓ Passed: below 1000
→ Suite: diagonal
  ✓ Passed: 3 4 5
  ✓ Passed: 5 12 13

All 4 tests passed! 🎉
```

Success! Now you're ready to try these next exercises on your own.

## Exercises

 1. (Easy) Write a function `circleArea` which computes the area of a circle with a given radius. Use the `pi` constant, which is defined in the `Numbers` module. _Hint_: don't forget to import `pi` by modifying the `import Data.Number` statement.
 1. (Medium) Write a function `leftoverCents` which takes an `Int` and returns what's leftover after dividing by `100`. Use the `rem` function. Search [Pursuit](https://pursuit.purescript.org/) for this function to learn about usage and which module to import it from. _Note:_ Your IDE may support auto-importing of this function if you accept the auto-completion suggestion.

## Conclusion

In this chapter, we installed the PureScript compiler and the Spago tool. We also learned how to write solutions to exercises and check these for correctness.

There will be many more exercises in the chapters ahead, and working through those really helps with learning the material. If you're stumped by any of the exercises, please reach out to any of the community resources listed in the [Getting Help](https://book.purescript.org/chapter1.html#getting-help) section of this book, or even file an issue in this [book's repo](https://github.com/purescript-contrib/purescript-book/issues). This reader feedback on which exercises could be made more approachable helps us improve the book.

Once you solve all the exercises in a chapter, you may compare your answers against those in the `no-peeking/Solutions.purs`. No peeking please without putting in an honest effort to solve these yourself though. And even if you are stuck, try asking a community member for help first, as we would prefer to give you a small hint rather than spoil the exercise. If you found a more elegant solution (that still only requires knowledge of covered content), please send us a PR.

The repo is continuously being revised, so be sure to check for updates before starting each new chapter.
