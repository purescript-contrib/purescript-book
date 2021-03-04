module Test.Main where

import Prelude
import Test.MySolutions

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
    suite "Exercise Group - Show Me" do
      test "Exercise - Show Point" do
        Assert.equal "(1.0, 2.0)"
          $ show
          $ Point {x: 1.0, y: 2.0}
    suite "Exercise Group - Common Type Classes" do
      let cpx real imaginary = Complex {real, imaginary}
      suite "Exercise - Show Complex" do
        test "Show" do
          Assert.equal "1.0+2.0i"
            $ show
            $ cpx 1.0 2.0
        test "Show Negative" do
          Assert.equal "1.0-2.0i"
            $ show
            $ cpx 1.0 (-2.0)
      suite "Exercise - Eq Complex" do
        test "equal" do
          Assert.equal (cpx 1.0 2.0)
            $ cpx 1.0 2.0
        test "not equal" do
          Assert.expectFailure "should not be equal"
            $ Assert.equal (cpx 5.0 2.0)
              $ cpx 1.0 2.0
      suite "Exercise - Semiring Complex" do
        test "add" do
          Assert.equal (cpx 4.0 6.0)
            $ add (cpx 1.0 2.0) (cpx 3.0 4.0)
        test "multiply" do
          Assert.equal (cpx (-5.0) 10.0)
            $ mul (cpx 1.0 2.0) (cpx 3.0 4.0)
      suite "Exercise - Ring Complex" do
        test "subtract" do
          Assert.equal (cpx 2.0 3.0)
            $ sub (cpx 3.0 5.0) (cpx 1.0 2.0)
      suite "Exercise - Show Shape" do
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
      test "Exercise - dedupShapes" do
        Assert.equal noDups
          $ dedupShapes withDups
      test "Exercise - dedupShapesFast" do
        Assert.equal noDups
          $ dedupShapesFast withDups
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
          test "Multiply Int concrete" do
            Assert.equal 15
              $ act m1 a
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
          test "Multiply String concrete" do
            Assert.equal "foofoofoo"
              $ act m1 a
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
          test "Multiply Array Int concrete" do
            Assert.equal [ 3, 6, 9 ]
              $ act m1 a
        suite "Multiply Array String" do
          let
            a = [ "foo", "bar", "baz" ]
          test "Multiply Array String mempty" do
            Assert.equal a
              $ act (mempty :: Multiply) a
          test "Multiply Array String append" do
            Assert.equal (act m1 (act m2 a))
              $ act (m1 <> m2) a
          test "Multiply Array String concrete" do
            Assert.equal
              [ "foofoofoo"
              , "barbarbar"
              , "bazbazbaz"
              ]
              $ act m1 a
      suite "Exercise - Action Class - actionSelf instance" do
        let
          a = Self m1
        test "Multiply Self mempty" do
          Assert.equal a
            $ act (mempty :: Multiply) a
        test "Multiply Self append" do
          Assert.equal (act m1 (act m2 a))
            $ act (m1 <> m2) a
        test "Multiply Self concrete" do
          Assert.equal (Self (Multiply 12))
            $ act m2 a
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

-}
runChapterExamples :: TestSuite
runChapterExamples =
  test "Todo for book maintainers - Add tests for chapter examples" do
    Assert.equal true true
