module Test.Main where

import Prelude
import Test.MySolutions
import Test.NoPeeking.Solutions  -- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.

import Data.Either (Either(..), fromLeft, fromRight)
import Data.List (List(..), foldM, (:))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (error, message, try)
import Effect.Unsafe (unsafePerformEffect)
import Data.Number (abs, pi)
import Test.Examples (countThrows, safeDivide)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    runChapterExamples
    {-  Move this block comment starting point to enable more tests
This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions. -}
    suite "Exercises Group - Monads and Applicatives" do
      suite "third" do
        test "No elements"
          $ Assert.equal Nothing
          $ third ([] :: Array Int)
        test "1 element"
          $ Assert.equal Nothing
          $ third [ 1 ]
        test "2 elements"
          $ Assert.equal Nothing
          $ third [ 1, 2 ]
        test "3 elements"
          $ Assert.equal (Just 3)
          $ third [ 1, 2, 3 ]
        test "4 elements"
          $ Assert.equal (Just 4)
          $ third [ 1, 2, 4, 3 ]
      suite "possibleSums" do
        test "[]"
          $ Assert.equal [ 0 ]
          $ possibleSums []
        test "[1, 2, 10]"
          $ Assert.equal [ 0, 1, 2, 3, 10, 11, 12, 13 ]
          $ possibleSums [ 1, 2, 10 ]
      suite "filterM" do
        suite "Array Monad" do
          let
            onlyPositives :: Int -> Array Boolean
            onlyPositives i = [ i >= 0 ]
          test "Empty"
            $ Assert.equal [ Nil ]
            $ filterM
                onlyPositives
                Nil
          test "Not Empty"
            $ Assert.equal [ (2 : 4 : Nil) ]
            $ filterM
                onlyPositives
                (2 : (-1) : 4 : Nil)
        suite "Maybe Monad" do
          let
            -- This is an impractical filtering function,
            -- and could be simplified, but it's fine for
            -- testing purposes.
            onlyPositiveEvenIntegers :: Int -> Maybe Boolean
            onlyPositiveEvenIntegers i = if i < 0 then Nothing else Just $ 0 == i `mod` 2
          test "Nothing"
            $ Assert.equal Nothing
            $ filterM
                onlyPositiveEvenIntegers
                (2 : 3 : (-1) : 4 : Nil)
          test "Just positive even integers"
            $ Assert.equal (Just (2 : 4 : Nil))
            $ filterM
                onlyPositiveEvenIntegers
                (2 : 3 : 4 : Nil)
      suite "exceptionDivide" do
        test "6 / 3"
          $ Assert.equal 2
          $ fromRight 0
          $ unsafePerformEffect
          $ try $ exceptionDivide 6 3
        test "6 / 0"
          $ Assert.equal "div zero"
          $ message
          $ fromLeft (error "")
          $ unsafePerformEffect
          $ try $ exceptionDivide 6 0
      suite "ST" do
        suite "estimatePi" do
          test "1000 terms of Gregory Series"
            $ Assert.assert "Estimated value of pi not within threshold"
            (abs (estimatePi 1000 - pi) < 0.002)
          test "1000000 terms of Gregory Series"
            $ Assert.assert "Estimated value of pi not within threshold"
            (abs (estimatePi 1000000 - pi) < 0.000002)
        suite "fibonacci" do
          test "40th Fibonacci number"
            $ Assert.equal 102334155 (fibonacci 40)
          test "45th Fibonacci number"
            $ Assert.equal 1134903170 (fibonacci 45)

{- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.
-}
runChapterExamples :: TestSuite
runChapterExamples =
  -- Testing chapter examples in book - for reader reference only
  suite "Chapter Examples" do
    suite "countThrows" do
      test "10" do
        Assert.equal [ [ 4, 6 ], [ 5, 5 ], [ 6, 4 ] ]
          $ countThrows 10
      test "12" do
        Assert.equal [ [ 6, 6 ] ]
          $ countThrows 12
    suite "safeDivide" do
      test "Just" do
        Assert.equal (Just 5)
          $ safeDivide 10 2
      test "Nothing" do
        Assert.equal Nothing
          $ safeDivide 10 0
    suite "foldM with safeDivide" do
      test "[5, 2, 2] has a Just answer" do
        Assert.equal (Just 5)
          $ foldM safeDivide 100 (5 : 2 : 2 : Nil)
      test "[5, 0, 2] has a Nothing answer" do
        Assert.equal (Nothing)
          $ foldM safeDivide 100 (5 : 0 : 2 : Nil)
