module Test.Main where

import Prelude
import Test.MySolutions
import Test.NoPeeking.Solutions  -- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.

import Data.Array (elem)
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
This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions. -}
    suite "Show Me!" do
      test "Show Point" do
        Assert.equal "(1.0, 2.0)"
          $ show
          $ Point {x: 1.0, y: 2.0}
    suite "Common Type Classes" do
      let cpx real imaginary = Complex {real, imaginary}
      suite "Show Complex" do
        test "possitve imaginary" do
          Assert.equal "1.0+2.0i"
            $ show
            $ cpx 1.0 2.0
        test "negative imaginary" do
          Assert.equal "1.0-2.0i"
            $ show
            $ cpx 1.0 (-2.0)
      suite "Eq Complex" do
        test "equal" do
          Assert.equal (cpx 1.0 2.0)
            $ cpx 1.0 2.0
        test "not equal" do
          Assert.expectFailure "should not be equal"
            $ Assert.equal (cpx 5.0 2.0)
              $ cpx 1.0 2.0
      suite "Semiring Complex" do
        test "add" do
          Assert.equal (cpx 4.0 6.0)
            $ add (cpx 1.0 2.0) (cpx 3.0 4.0)
        let v = cpx 1.2 3.4
        test "add zero" do
          Assert.equal v
            $ add v zero
        test "multiply" do
          Assert.equal (cpx (-5.0) 10.0)
            $ mul (cpx 1.0 2.0) (cpx 3.0 4.0)
        test "multiply one" do
          Assert.equal v
            $ mul v one
      suite "Ring Complex" do
        test "subtract" do
          Assert.equal (cpx 2.0 3.0)
            $ sub (cpx 3.0 5.0) (cpx 1.0 2.0)
      suite "Show Shape" do
        test "circle" do
          Assert.equal "(Circle (1.0, 2.0) 3.0)"
            $ show $ Circle (Point {x: 1.0, y: 2.0}) 3.0
        test "rectangle" do
          Assert.equal "(Rectangle (1.0, 2.0) 3.0 4.0)"
            $ show $ Rectangle (Point {x: 1.0, y: 2.0}) 3.0 4.0
        test "line" do
          Assert.equal "(Line (1.0, 2.0) (3.0, 4.0))"
            $ show $ Line (Point {x: 1.0, y: 2.0}) (Point {x: 3.0, y: 4.0})
        test "text" do
          Assert.equal "(Text (1.0, 2.0) \"Hello\")"
            $ show $ Text (Point {x: 1.0, y: 2.0}) "Hello"
    suite "Type Class Constraints" do
      suite "Eq NonEmpty" do
        test "equals" do
          Assert.equal (NonEmpty 1 [ 2, 3 ])
            $ NonEmpty 1 [ 2, 3 ]
        test "not equals" do
          Assert.expectFailure "should not be equal"
            $ Assert.equal (NonEmpty 1 [ 2, 3 ])
            $ NonEmpty 2 [ 2, 3 ]
      suite "Semigroup NonEmpty" do
        test "append" do
          Assert.equal (NonEmpty 1 [ 2, 3, 4, 5, 6 ])
            $ NonEmpty 1 [ 2, 3 ]
            <> NonEmpty 4 [ 5, 6 ]
      suite "Functor NonEmpty" do
        test "map" do
          Assert.equal (NonEmpty 10 [ 20, 30 ])
            $ map (_ * 10)
            $ NonEmpty 1 [ 2, 3 ]
      suite "Ord Extended" do
        -- Type annotation necessary to ensure there is an Ord instance for inner type (Int in this case)
        test "infinity equals infinity" do
          Assert.equal EQ
            $ compare Infinite (Infinite :: Extended Int)
        test "infinity > finite" do
          Assert.equal GT
            $ compare Infinite
            $ Finite 5
        test "finite < infinity" do
          Assert.equal LT
            $ compare (Finite 5) Infinite
        test "finite equals finite" do
          Assert.equal EQ
            $ compare (Finite 5)
            $ Finite 5
        test "finite > finite" do
          Assert.equal GT
            $ compare (Finite 6)
            $ Finite 5
        test "finite < finite" do
          Assert.equal LT
            $ compare (Finite 5)
            $ Finite 6
      suite "Foldable NonEmpty" do
        test "foldl" do
          Assert.equal 123
            $ foldl (\acc x -> acc * 10 + x) 0
            $ NonEmpty 1 [ 2, 3 ]
        test "foldr" do
          Assert.equal 321
            $ foldr (\x acc -> acc * 10 + x) 0
            $ NonEmpty 1 [ 2, 3 ]
        test "foldMap" do
          Assert.equal "123"
            $ foldMap (\x -> show x)
            $ NonEmpty 1 [ 2, 3 ]
      suite "Foldable OneMore" do
        test "foldl" do
          Assert.equal 123
            $ foldl (\acc x -> acc * 10 + x) 0
            $ OneMore 1 (2 : 3 : Nil)
        test "foldr" do
          Assert.equal 321
            $ foldr (\x acc -> acc * 10 + x) 0
            $ OneMore 1 (2 : 3 : Nil)
        test "foldMap" do
          Assert.equal "123"
            $ foldMap (\x -> show x)
            $ OneMore 1 (2 : 3 : Nil)
      let
        withDups =
          [ Circle (Point {x: 1.0, y: 2.0}) 3.0
          , Circle (Point {x: 3.0, y: 2.0}) 3.0
          , Circle (Point {x: 1.0, y: 2.0}) 3.0
          , Circle (Point {x: 2.0, y: 2.0}) 3.0
          ]
        noDups =
          [ Circle (Point {x: 1.0, y: 2.0}) 3.0
          , Circle (Point {x: 3.0, y: 2.0}) 3.0
          , Circle (Point {x: 2.0, y: 2.0}) 3.0
          ]
      test "dedupShapes" do
        Assert.equal noDups
          $ dedupShapes withDups
      test "dedupShapesFast" do
        Assert.equal noDups
          $ dedupShapesFast withDups
    suite "Multi Parameter Type Classes " do
      test "unsafeMaximum" do
        Assert.equal 42
          $ unsafePartial
          $ unsafeMaximum [ 1, 2, 42, 3 ]
      let
        m1 = Multiply 3
        m2 = Multiply 4
      -- Getting Multiply Int to work is a warm-up
      suite "Action Multiply Int" do
        let
          a = 5
        test "act mempty" do
          Assert.equal a
            $ act (mempty :: Multiply) a
        test "act appended" do
          Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
        test "concrete" do
          let expectOneOf = [ 1, 15, 125 ]
              got = act m1 a
          Assert.assert ("expected one of " <> show expectOneOf <> ", got " <> show got)
            $ elem got expectOneOf
      -- Multiply String is the actual exercise question
      suite "Action Multiply String" do
        let
          a = "foo"
        test "act mempty" do
          Assert.equal a
            $ act (mempty :: Multiply) a
        test "act appended" do
          Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
        test "concrete" do
          Assert.equal "foofoofoo"
            $ act m1 a
      suite "Action m (Array a)" do
        suite "Action Multiply (Array Int)" do
          let
            a = [ 1, 2, 3 ]
          test "act mempty" do
            Assert.equal a
              $ act (mempty :: Multiply) a
          test "act appended" do
            Assert.equal (act m1 (act m2 a))
              $ act (m1 <> m2) a
          test "concrete" do
            let expectOneOf = [[ 0, 0, 1], [ 3, 6, 9 ], [ 1, 8, 27 ]]
                got = act m1 a
            Assert.assert ("expected one of " <> show expectOneOf <> ", got " <> show got)
              $ elem got expectOneOf
        suite "Action Multiply (Array String)" do
          let
            a = [ "foo", "bar", "baz" ]
          test "act mempty" do
            Assert.equal a
              $ act (mempty :: Multiply) a
          test "act appended" do
            Assert.equal (act m1 (act m2 a))
              $ act (m1 <> m2) a
          test "concrete" do
            Assert.equal
              [ "foofoofoo"
              , "barbarbar"
              , "bazbazbaz"
              ]
              $ act m1 a
      suite "Action m (Self m)" do
        let
          a = Self m1
        test "act mempty" do
          Assert.equal a
            $ act (mempty :: Multiply) a
        test "act appended" do
          Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
        test "concrete" do
          Assert.equal (Self (Multiply 12))
            $ act m2 a
    suite "A Type Class for Hashes" do
      suite "arrayHasDuplicates" do
        test "no dupe" do
          Assert.equal false
            $ arrayHasDuplicates [ 1, 2, 3 ]
        test "dupe" do
          Assert.equal true
            $ arrayHasDuplicates [ 1, 1, 3 ]
        test "only hash dupe" do
          Assert.equal false
            $ arrayHasDuplicates [ 65536, 1, 2, 3 ]
      suite "Hashable Hour" do
        test "match" do
          Assert.equal (hash $ Hour 1)
            $ hash
            $ Hour 13
        test "mismatch" do
          Assert.expectFailure "should not be equal"
            $ Assert.equal (hash $ Hour 1)
            $ hash
            $ Hour 14

{- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.
-}
runChapterExamples :: TestSuite
runChapterExamples =
  test "Todo for book maintainers - Add tests for chapter examples" do
    Assert.equal true true
