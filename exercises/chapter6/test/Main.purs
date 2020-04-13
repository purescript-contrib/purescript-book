module Test.Main where

import Prelude
import Data.Foldable (foldMap, foldl, foldr)
import Data.Hashable (hash)
import Data.List (List(..), (:))
import Effect (Effect)
import Partial.Unsafe (unsafePartial)
import Test.Solutions (Complex(..), Extended(..), Hour(..), Multiply(..), NonEmpty(..), OneMore(..), Self(..), act, arrayHasDuplicates, unsafeMaximum)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    test "Initial passing test"
      $ Assert.equal true true
    -- Tests for the first exercise in this chapter (Show Shape)
    -- can be found at the end of the previous chapter (chapter 5).
    suite "Exercise Group 1" do
      suite "Exercise 1 - Show and Eq for Complex" do
        test "Show Complex"
          $ Assert.equal "1.0+2.0i"
          $ show
          $ Complex { real: 1.0, imaginary: 2.0 }
        test "Show Negative Complex"
          $ Assert.equal "1.0-2.0i"
          $ show
          $ Complex { real: 1.0, imaginary: -2.0 }
        test "Eq Complex"
          $ Assert.equal (Complex { real: 1.0, imaginary: 2.0 })
          $ Complex { real: 1.0, imaginary: 2.0 }
        test "Eq Complex - not equal"
          $ Assert.expectFailure "should not be equal"
          $ Assert.equal (Complex { real: 5.0, imaginary: 2.0 })
          $ Complex { real: 1.0, imaginary: 2.0 }
    suite "Exercise Group 2" do
      suite "Exercise 1 - Eq for NonEmpty" do
        test "NonEmpty equals"
          $ Assert.equal (NonEmpty 1 [ 2, 3 ])
          $ NonEmpty 1 [ 2, 3 ]
        test "NonEmpty not equals"
          $ Assert.expectFailure "should not be equal"
          $ Assert.equal (NonEmpty 1 [ 2, 3 ])
          $ NonEmpty 2 [ 2, 3 ]
      suite "Exercise 2 - Semigroup for NonEmpty" do
        test "NonEmpty append"
          $ Assert.equal (NonEmpty 1 [ 2, 3, 4, 5, 6 ])
          $ NonEmpty 1 [ 2, 3 ]
          <> NonEmpty 4 [ 5, 6 ]
      suite "Exercise 3 - Functor for NonEmpty" do
        test "NonEmpty append"
          $ Assert.equal (NonEmpty 10 [ 20, 30 ])
          $ map (_ * 10)
          $ NonEmpty 1 [ 2, 3 ]
      suite "Exercise 4 - Ord for Extended" do
        -- Type annotation necessary to ensure there is an Ord instance for inner type (Int in this case)
        test "Extended compare inf inf"
          $ Assert.equal EQ
          $ compare Infinite (Infinite :: Extended Int)
        test "Extended compare inf 5"
          $ Assert.equal GT
          $ compare Infinite
          $ Finite 5
        test "Extended compare 5 inf"
          $ Assert.equal LT
          $ compare (Finite 5) Infinite
        test "Extended compare 5 5"
          $ Assert.equal EQ
          $ compare (Finite 5)
          $ Finite 5
        test "Extended compare 6 5"
          $ Assert.equal GT
          $ compare (Finite 6)
          $ Finite 5
        test "Extended compare 5 6"
          $ Assert.equal LT
          $ compare (Finite 5)
          $ Finite 6
      suite "Exercise 5 - Foldable for NonEmpty" do
        test "NonEmpty foldl"
          $ Assert.equal 123
          $ foldl (\acc x -> acc * 10 + x) 0
          $ NonEmpty 1 [ 2, 3 ]
        test "NonEmpty foldr"
          $ Assert.equal 321
          $ foldr (\x acc -> acc * 10 + x) 0
          $ NonEmpty 1 [ 2, 3 ]
        test "NonEmpty foldMap"
          $ Assert.equal "123"
          $ foldMap (\x -> show x)
          $ NonEmpty 1 [ 2, 3 ]
      suite "Exercise 6 - Foldable for OneMore" do
        test "OneMore foldl"
          $ Assert.equal 123
          $ foldl (\acc x -> acc * 10 + x) 0
          $ OneMore 1 (2 : 3 : Nil)
        test "OneMore foldr"
          $ Assert.equal 321
          $ foldr (\x acc -> acc * 10 + x) 0
          $ OneMore 1 (2 : 3 : Nil)
        test "OneMore foldMap"
          $ Assert.equal "123"
          $ foldMap (\x -> show x)
          $ OneMore 1 (2 : 3 : Nil)
    suite "Exercise Group 3" do
      suite "Exercise 1 - Partial maximum" do
        test "unsafeMaximum"
          $ Assert.equal 42
          $ unsafePartial
          $ unsafeMaximum [ 1, 2, 42, 3 ]
      let
        m1 = Multiply 3

        m2 = Multiply 4
      suite "Exercise 2 - Action Class" do
        -- Getting Multiply Int to work is a warm-up
        suite "Multiply Int" do
          let
            a = 5
          test "Multiply Int mempty"
            $ Assert.equal a
            $ act (mempty :: Multiply) a
          test "Multiply Int append"
            $ Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
        -- Multiply String is the actual exercise question
        suite "Multiply String" do
          let
            a = "foo"
          test "Multiply String mempty"
            $ Assert.equal a
            $ act (mempty :: Multiply) a
          test "Multiply String append"
            $ Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
      suite "Exercise 3 - Action Array" do
        suite "Multiply Array Int" do
          let
            a = [ 1, 2, 3 ]
          test "Multiply Array Int mempty"
            $ Assert.equal a
            $ act (mempty :: Multiply) a
          test "Multiply Arary Int append"
            $ Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
        suite "Multiply Array String" do
          let
            a = [ "foo", "bar", "baz" ]
          test "Multiply Array String mempty"
            $ Assert.equal a
            $ act (mempty :: Multiply) a
          test "Multiply Array String append"
            $ Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
      suite "Exercise 4 - Action Self" do
        let
          a = Self m1
        test "Multiply Self mempty"
          $ Assert.equal a
          $ act (mempty :: Multiply) a
        test "Multiply Self append"
          $ Assert.equal (act m1 (act m2 a))
          $ act (m1 <> m2) a
    suite "Exercise Group 4" do
      suite "Exercise 2 - Array Duplicates" do
        test "No dupe"
          $ Assert.equal false
          $ arrayHasDuplicates [ 1, 2, 3 ]
        test "Dupe"
          $ Assert.equal true
          $ arrayHasDuplicates [ 1, 1, 3 ]
        test "Only hash dupe"
          $ Assert.equal false
          $ arrayHasDuplicates [ 65536, 1, 2, 3 ]
      suite "Exercise 3 - Hash Hour" do
        test "Match"
          $ Assert.equal (hash $ Hour 1)
          $ hash
          $ Hour 13
        test "Mismatch"
          $ Assert.expectFailure "should not be equal"
          $ Assert.equal (hash $ Hour 1)
          $ hash
          $ Hour 14
