module Test.Main where

import Prelude
import Data.AddressBook
  ( examplePerson
  , PhoneType(..)
  )
import Data.Array
  ( filter
  , null
  )
import Data.List
  ( List(..)
  , foldM
  , (:)
  )
import Data.Maybe (Maybe(..))
import Effect (Effect)
{- | Your own code is included -}
import MySolutions
  ( answerTrue
  -- , filterM
  -- , possibleSums
  -- , third
  )
{- -}
{- | Comment out the following import to instead apply the unit tests to your MySolutions above -}
import OfficialSolutions
  ( filterM
  , possibleSums
  , third
  )
{- -}
import Test.Examples
  ( countThrows
  , safeDivide
  )
import Test.Unit
  -- ( TestF
  ( suite
  , test
  )
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    suite "Verifying unit test environment" do
      test "Initial test"
        $ Assert.equal true
        $ answerTrue
    suite "Exercises Group 1" do
      suite "Exercise 1 - function third" do
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
      suite "Exercise 2 - function possibleSums" do
        test "[]"
          $ Assert.equal [ 0 ]
          $ possibleSums []
        test "[1, 2, 10]"
          $ Assert.equal [ 0, 1, 2, 3, 10, 11, 12, 13 ]
          $ possibleSums [ 1, 2, 10 ]
      suite "Exercise 3 - ap and apply" do
        test "NO UNIT TESTS"
          $ Assert.equal true true
      suite "Exercise 4 - Monad laws for Maybe" do
        test "NO UNIT TESTS"
          $ Assert.equal true true
      suite "Exercise 5 - function filterM" do
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
      suite "Exercise 6 - Prove lift2 property" do
        test "NO UNIT TESTS"
          $ Assert.equal true true
    suite "Exercises Group 2" do
      suite "Exercise 1 - Rewrite 'safeDivide' to use 'throwException'" do
        test "TODO"
          $ Assert.equal true true
      suite "Exercise 2 - ST exercise" do
        test "TODO"
          $ Assert.equal true true
    suite "Exercises Group 3" do
      suite "Exercise 1 - Add a work phone" do
        test "Work phone included"
          $ Assert.assert "Work phone missing"
          $ not null
          $ filter (\p -> p.type == WorkPhone) examplePerson.phones
      suite "Exercise 2 - Validation errors separated by blank line" do
        test "NO UNIT TESTS"
          $ Assert.equal true true
      suite "Exercise 3 - Validation error associated with field" do
        test "NO UNIT TESTS"
          $ Assert.equal true true
    -- Testing chapter examples in book - for reader reference only
    suite "Chapter Examples" do
      suite "Testing countThrows" do
        test "10"
          $ Assert.equal [ [ 4, 6 ], [ 5, 5 ], [ 6, 4 ] ]
          $ countThrows 10
        test "12"
          $ Assert.equal [ [ 6, 6 ] ]
          $ countThrows 12
      suite "Testing foldM and safeDivide" do
        test "[5, 2, 2] has a Just answer"
          $ Assert.equal (Just 5)
          $ foldM safeDivide 100 (5 : 2 : 2 : Nil)
        test "[5, 0, 2] has a Nothing answer"
          $ Assert.equal (Nothing)
          $ foldM safeDivide 100 (5 : 0 : 2 : Nil)
