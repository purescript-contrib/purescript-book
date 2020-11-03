module Test.Main where

import Prelude
import Test.MySolutions
import Test.NoPeeking.Solutions  -- Note to reader: Delete this line

import Data.Foldable (foldMap, foldl, foldr)
import Data.Hashable (hash)
import Data.List (List(..), (:))
import Effect (Effect)
import Partial.Unsafe (unsafePartial)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    runChapterExamples
    {-  Move this block comment starting point to enable more tests
Note to reader: Delete this line to expand comment block -}
    test "Exercise Group - Show Me" do
      -- Tests for the first exercise in this chapter (Show Shape)
      -- can be found at the end of the previous chapter (chapter 5).
      Assert.equal true true
    suite "Exercise Group - Common Type Classes" do
      suite "Exercise - Show and Eq for Complex" do
        test "Show Complex" do
          Assert.equal "1.0+2.0i"
            $ show
            $ Complex { real: 1.0, imaginary: 2.0 }
        test "Show Negative Complex" do
          Assert.equal "1.0-2.0i"
            $ show
            $ Complex { real: 1.0, imaginary: -2.0 }
        test "Eq Complex" do
          Assert.equal (Complex { real: 1.0, imaginary: 2.0 })
            $ Complex { real: 1.0, imaginary: 2.0 }
        test "Eq Complex - not equal" do
          Assert.expectFailure "should not be equal"
            $ Assert.equal (Complex { real: 5.0, imaginary: 2.0 })
            $ Complex { real: 1.0, imaginary: 2.0 }
    suite "Exercise Group - Constraints and Dependencies" do
      suite "Exercise - Eq for NonEmpty" do
        test "NonEmpty equals" do
          Assert.equal (NonEmpty 1 [ 2, 3 ])
            $ NonEmpty 1 [ 2, 3 ]
        test "NonEmpty not equals" do
          Assert.expectFailure "should not be equal"
            $ Assert.equal (NonEmpty 1 [ 2, 3 ])
            $ NonEmpty 2 [ 2, 3 ]
      suite "Exercise - Semigroup for NonEmpty" do
        test "NonEmpty append" do
          Assert.equal (NonEmpty 1 [ 2, 3, 4, 5, 6 ])
            $ NonEmpty 1 [ 2, 3 ]
            <> NonEmpty 4 [ 5, 6 ]
      suite "Exercise - Functor for NonEmpty" do
        test "NonEmpty append" do
          Assert.equal (NonEmpty 10 [ 20, 30 ])
            $ map (_ * 10)
            $ NonEmpty 1 [ 2, 3 ]
      suite "Exercise - Ord for Extended" do
        -- Type annotation necessary to ensure there is an Ord instance for inner type (Int in this case)
        test "Extended compare inf inf" do
          Assert.equal EQ
            $ compare Infinite (Infinite :: Extended Int)
        test "Extended compare inf 5" do
          Assert.equal GT
            $ compare Infinite
            $ Finite 5
        test "Extended compare 5 inf" do
          Assert.equal LT
            $ compare (Finite 5) Infinite
        test "Extended compare 5 5" do
          Assert.equal EQ
            $ compare (Finite 5)
            $ Finite 5
        test "Extended compare 6 5" do
          Assert.equal GT
            $ compare (Finite 6)
            $ Finite 5
        test "Extended compare 5 6" do
          Assert.equal LT
            $ compare (Finite 5)
            $ Finite 6
      suite "Exercise - Foldable for NonEmpty" do
        test "NonEmpty foldl" do
          Assert.equal 123
            $ foldl (\acc x -> acc * 10 + x) 0
            $ NonEmpty 1 [ 2, 3 ]
        test "NonEmpty foldr" do
          Assert.equal 321
            $ foldr (\x acc -> acc * 10 + x) 0
            $ NonEmpty 1 [ 2, 3 ]
        test "NonEmpty foldMap" do
          Assert.equal "123"
            $ foldMap (\x -> show x)
            $ NonEmpty 1 [ 2, 3 ]
      suite "Exercise - Foldable for OneMore" do
        test "OneMore foldl" do
          Assert.equal 123
            $ foldl (\acc x -> acc * 10 + x) 0
            $ OneMore 1 (2 : 3 : Nil)
        test "OneMore foldr" do
          Assert.equal 321
            $ foldr (\x acc -> acc * 10 + x) 0
            $ OneMore 1 (2 : 3 : Nil)
        test "OneMore foldMap" do
          Assert.equal "123"
            $ foldMap (\x -> show x)
            $ OneMore 1 (2 : 3 : Nil)
    suite "Exercise Group - More or less than one Type argument" do
      test "Exercise - unsafeMaximum" do
        Assert.equal 42
          $ unsafePartial
          $ unsafeMaximum [ 1, 2, 42, 3 ]
      let
        m1 = Multiply 3

        m2 = Multiply 4
      suite "Exercise - Action Class - repeatAction instance" do
        -- Getting Multiply Int to work is a warm-up
        suite "Multiply Int" do
          let
            a = 5
          test "Multiply Int mempty" do
            Assert.equal a
              $ act (mempty :: Multiply) a
          test "Multiply Int append" do
            Assert.equal (act m1 (act m2 a))
              $ act (m1 <> m2) a
          test "Multiply Int append concrete" do
            Assert.equal 60
              $ act (m1 <> m2) a
        -- Multiply String is the actual exercise question
        suite "Multiply String" do
          let
            a = "foo"
          test "Multiply String mempty" do
            Assert.equal a
              $ act (mempty :: Multiply) a
          test "Multiply String append" do
            Assert.equal (act m1 (act m2 a))
              $ act (m1 <> m2) a
          test "Multiply String append concrete" do
            Assert.equal "foofoofoofoofoofoofoofoofoofoofoofoo"
              $ act (m1 <> m2) a
      suite "Exercise - Action Class - actionArray instance" do
        suite "Multiply Array Int" do
          let
            a = [ 1, 2, 3 ]
          test "Multiply Array Int mempty" do
            Assert.equal a
              $ act (mempty :: Multiply) a
          test "Multiply Array Int append" do
            Assert.equal (act m1 (act m2 a))
              $ act (m1 <> m2) a
          test "Multiply Array Int append concrete" do
            Assert.equal [ 12, 24, 36 ]
              $ act (m1 <> m2) a
        suite "Multiply Array String" do
          let
            a = [ "foo", "bar", "baz" ]
          test "Multiply Array String mempty" do
            Assert.equal a
              $ act (mempty :: Multiply) a
          test "Multiply Array String append" do
            Assert.equal (act m1 (act m2 a))
              $ act (m1 <> m2) a
          test "Multiply Array String append concrete" do
            Assert.equal
              [ "foofoofoofoofoofoofoofoofoofoofoofoo"
              , "barbarbarbarbarbarbarbarbarbarbarbar"
              , "bazbazbazbazbazbazbazbazbazbazbazbaz"
              ]
              $ act (m1 <> m2) a
      suite "Exercise - Action Class - actionSelf instance" do
        let
          a = Self m1
        test "Multiply Self mempty" do
          Assert.equal a
            $ act (mempty :: Multiply) a
        test "Multiply Self append" do
          Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
        test "Multiply Self append concrete" do
          Assert.equal 72
            $ act (act (m1 <> m2) a) 2
    suite "Exercise Group - Hashes" do
      suite "Exercise - arrayHasDuplicates" do
        test "No dupe" do
          Assert.equal false
            $ arrayHasDuplicates [ 1, 2, 3 ]
        test "Dupe" do
          Assert.equal true
            $ arrayHasDuplicates [ 1, 1, 3 ]
        test "Only hash dupe" do
          Assert.equal false
            $ arrayHasDuplicates [ 65536, 1, 2, 3 ]
      suite "Exercise - hashHour instance" do
        test "Match" do
          Assert.equal (hash $ Hour 1)
            $ hash
            $ Hour 13
        test "Mismatch" do
          Assert.expectFailure "should not be equal"
            $ Assert.equal (hash $ Hour 1)
            $ hash
            $ Hour 14

{- Note to reader: Delete this line to expand comment block
-}
runChapterExamples :: TestSuite
runChapterExamples =
  test "Todo for book maintainers - Add tests for chapter examples" do
    Assert.equal true true
