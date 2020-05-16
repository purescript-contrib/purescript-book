module Test.Main where

import Prelude
import Test.Examples
import Test.Solutions
import Control.Monad.Free (Free)
import Data.Argonaut (decodeJson, encodeJson)
import Data.Either (Either(..), isLeft)
import Data.Function.Uncurried (runFn2, runFn3)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Pair (Pair(..))
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Uncurried (runEffectFn2)
import Test.URI (encodeURIComponent)
import Test.Unit (TestF, suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    runChapterExamples
    suite "Exercise Group - Calling JavaScript" do
      suite "Exercise - volumeFn" do
        test "1 2 3" do
          Assert.equal 6.0
            $ runFn3 volumeFn 1.0 2.0 3.0
        test "1 0 3" do
          Assert.equal 0.0
            $ runFn3 volumeFn 1.0 0.0 3.0
      suite "Exercise - volumeArrow" do
        test "1 2 3" do
          Assert.equal 6.0
            $ volumeArrow 1.0 2.0 3.0
        test "1 0 3" do
          Assert.equal 0.0
            $ volumeArrow 1.0 0.0 3.0
    suite "Exercise Group - Passing Simple Types" do
      suite "Exercise - cumulativeSumsComplex" do
        test "sequential" do
          Assert.equal
            [ { real: 1.0, imag: 2.0 }
            , { real: 4.0, imag: 6.0 }
            , { real: 9.0, imag: 12.0 }
            ]
            $ cumulativeSumsComplex
                [ { real: 1.0, imag: 2.0 }
                , { real: 3.0, imag: 4.0 }
                , { real: 5.0, imag: 6.0 }
                ]
    suite "Exercise Group - Beyond Simple Types" do
      suite "Exercise - quadraticRoots" do
        let
          helper :: String -> Quadratic -> Complex -> Complex -> Free TestF Unit
          helper testName poly r1 r2 =
            test testName do
              Assert.equal (orderCpx $ Pair r1 r2)
                $ orderCpx
                $ quadraticRoots poly
        helper "Real"
          { a: 1.0, b: 2.0, c: -3.0 }
          { real: 1.0, imag: 0.0 }
          { real: -3.0, imag: 0.0 }
        helper "Imaginary"
          { a: 4.0, b: 0.0, c: 16.0 }
          { real: 0.0, imag: 2.0 }
          { real: 0.0, imag: -2.0 }
        helper "Complex"
          { a: 2.0, b: 2.0, c: 5.0 }
          { real: -0.5, imag: 1.5 }
          { real: -0.5, imag: -1.5 }
        helper "Repeated"
          { a: 3.0, b: -6.0, c: 3.0 }
          { real: 1.0, imag: 0.0 }
          { real: 1.0, imag: 0.0 }
    suite "Exercise Group - JSON" do
      suite "Exercise - valuesOfMap" do
        test "Items" do
          Assert.equal (Right $ Set.fromFoldable [ 1, 2 ])
            $ valuesOfMap
            $ Map.fromFoldable [ Tuple "hat" 1, Tuple "cat" 2 ]
        test "Empty" do
          Assert.equal (Right $ Set.fromFoldable [])
            $ valuesOfMap
            $ Map.fromFoldable []
      suite "Exercise - valuesOfMapGeneric" do
        test "String Int" do
          Assert.equal (Right $ Set.fromFoldable [ 1, 2 ])
            $ valuesOfMapGeneric
            $ Map.fromFoldable [ Tuple "hat" 1, Tuple "cat" 2 ]
        test "(Array Int) String" do
          Assert.equal (Right $ Set.fromFoldable [ "hat", "cat" ])
            $ valuesOfMapGeneric
            $ Map.fromFoldable [ Tuple [ 1, 3, 5 ] "hat", Tuple [ 43, 8 ] "cat" ]
      suite "Exercise - quadraticRootsSet" do
        let
          helper :: String -> Quadratic -> Complex -> Complex -> Free TestF Unit
          helper testName poly r1 r2 =
            test testName do
              Assert.equal (Right $ Set.fromFoldable [ r1, r2 ])
                $ quadraticRootsSet poly
        helper "Real"
          { a: 1.0, b: 2.0, c: -3.0 }
          { real: 1.0, imag: 0.0 }
          { real: -3.0, imag: 0.0 }
        helper "Imaginary"
          { a: 4.0, b: 0.0, c: 16.0 }
          { real: 0.0, imag: 2.0 }
          { real: 0.0, imag: -2.0 }
        helper "Complex"
          { a: 2.0, b: 2.0, c: 5.0 }
          { real: -0.5, imag: 1.5 }
          { real: -0.5, imag: -1.5 }
        helper "Repeated"
          { a: 3.0, b: -6.0, c: 3.0 }
          { real: 1.0, imag: 0.0 }
          { real: 1.0, imag: 0.0 }
      suite "Exercise - quadraticRootsSafe" do
        let
          helper :: String -> Quadratic -> Complex -> Complex -> Free TestF Unit
          helper testName poly r1 r2 =
            test testName do
              Assert.equal (Right $ orderCpx $ Pair r1 r2)
                $ map orderCpx
                $ quadraticRootsSafe poly
        helper "Real"
          { a: 1.0, b: 2.0, c: -3.0 }
          { real: 1.0, imag: 0.0 }
          { real: -3.0, imag: 0.0 }
        helper "Imaginary"
          { a: 4.0, b: 0.0, c: 16.0 }
          { real: 0.0, imag: 2.0 }
          { real: 0.0, imag: -2.0 }
        helper "Complex"
          { a: 2.0, b: 2.0, c: 5.0 }
          { real: -0.5, imag: 1.5 }
          { real: -0.5, imag: -1.5 }
        helper "Repeated"
          { a: 3.0, b: -6.0, c: 3.0 }
          { real: 1.0, imag: 0.0 }
          { real: 1.0, imag: 0.0 }
      test "Exercise - decodeArray2D" do
        let
          arr = [ [ 1, 2, 3 ], [ 4, 5 ], [ 6 ] ]
        Assert.equal (Right arr)
          $ decodeArray2D
          $ show arr -- the correct JSON string happens to also be produced by show
      test "Exercise - encode decode Tree" do
        let
          tree = Branch (Leaf 1) (Branch (Leaf 2) (Leaf 3))
        Assert.equal (Right tree)
          $ decodeJson
          $ encodeJson tree
      suite "Exercise - IntOrString" do
        test "IoS to IoS Int" do
          let
            ios = IntOrString_Int 1
          Assert.equal (Right ios)
            $ decodeJson
            $ encodeJson ios
        test "IoS to IoS String" do
          let
            ios = IntOrString_String "one"
          Assert.equal (Right ios)
            $ decodeJson
            $ encodeJson ios
        test "Int to IoS" do
          let
            int = 1
          Assert.equal (Right $ IntOrString_Int int)
            $ decodeJson
            $ encodeJson int
        test "String to IoS" do
          let
            str = "one"
          Assert.equal (Right $ IntOrString_String str)
            $ decodeJson
            $ encodeJson str
        test "IoS to Int" do
          let
            int = 1
          Assert.equal (Right int)
            $ decodeJson
            $ encodeJson
            $ IntOrString_Int int
        test "IoS to String" do
          let
            str = "one"
          Assert.equal (Right str)
            $ decodeJson
            $ encodeJson
            $ IntOrString_String str
        test "Neither, a Number instead" do
          let
            (decoded :: Either _ IntOrString) = decodeJson $ encodeJson 1.5
          Assert.assert "Got a Right, should be Left" $ isLeft decoded

{-  Move this block comment starting point to enable more tests
-}
-- Put in ascending order by real, then imag components
orderCpx :: Pair Complex -> Pair Complex
orderCpx (Pair c1 c2)
  | c1.real < c2.real = Pair c1 c2
  | c1.real > c2.real = Pair c2 c1
  | c1.imag < c2.imag = Pair c1 c2
  | otherwise = Pair c2 c1

runChapterExamples :: Free TestF Unit
runChapterExamples =
  suite "Chapter Examples" do
    test "uri" do
      Assert.equal "Hello%20World"
        $ encodeURIComponent "Hello World"
    test "square" do
      Assert.equal 25.0
        $ square 5.0
    test "diagonal" do
      Assert.equal 5.0
        $ runFn2 diagonal 3.0 4.0
    test "diagonalNested" do
      Assert.equal 5.0
        $ diagonalNested 3.0 4.0
    test "diagonalArrow" do
      Assert.equal 5.0
        $ diagonalArrow 3.0 4.0
    test "uncurriedAdd" do
      Assert.equal 13
        $ runFn2 uncurriedAdd 3 10
    test "curriedAdd" do
      Assert.equal 13
        $ curriedAdd 3 10
    test "cumulativeSums" do
      Assert.equal [ 1, 3, 6 ]
        $ cumulativeSums [ 1, 2, 3 ]
    test "addComplex" do
      Assert.equal { imag: 6.0, real: 4.0 }
        $ addComplex { real: 1.0, imag: 2.0 } { real: 3.0, imag: 4.0 }
    test "maybeHead - Just" do
      Assert.equal (Just 1)
        $ maybeHead [ 1, 2, 3 ]
    test "maybeHead - Nothing" do
      Assert.equal Nothing
        $ maybeHead ([] :: Array Int)
    test "isEmpty - false" do
      Assert.equal false
        $ isEmpty [ 1, 2, 3 ]
    test "isEmpty - true" do
      Assert.equal true
        $ isEmpty []
    -- It is not possible to test the thrown exception
    -- by catching with a `try` because `unsafeHead`
    -- lacks `Effect` in its return type.
    -- Lifting with `pure` doesn't help in this situation.
    test "unsafeHead - value" do
      Assert.equal 1
        $ unsafeHead [ 1, 2, 3 ]
    test "bold" do
      Assert.equal "(TUPLE 1 \"HAT\")!!!"
        $ bold
        $ Tuple 1 "Hat"
    test "showEquality - not equal" do
      Assert.equal "Nothing is not equal to (Just 5)"
        $ showEquality Nothing (Just 5)
    test "showEquality - equivalent" do
      Assert.equal "Equivalent"
        $ showEquality [ 1, 2 ] [ 1, 2 ]
    -- Cannot test for actual logged value
    test "yell" do
      result <- liftEffect $ yell $ Tuple 1 "Hat"
      Assert.equal unit result
    test "diagonalLog" do
      result <- liftEffect $ runEffectFn2 diagonalLog 3.0 4.0
      Assert.equal 5.0 result
    test "sleep" do
      result <- sleep 1
      Assert.equal unit result
    test "diagonalAsync" do
      result <- diagonalAsync 1 3.0 4.0
      Assert.equal 5.0 result
    suite "cumulativeSums Json" do
      test "broken" do
        Assert.equal (Left "Couldn't decode Array (Failed at index 3): Value is not a Number")
          $ cumulativeSumsDecodedBroken [ 1, 2, 3 ]
      test "working" do
        Assert.equal (Right [ 1, 3, 6 ])
          $ cumulativeSumsDecodedWorking [ 1, 2, 3 ]
    suite "addComplex Json" do
      test "broken" do
        Assert.equal (Left "JSON was missing expected field: imag")
          $ addComplexDecodedBroken { real: 1.0, imag: 2.0 } { real: 3.0, imag: 4.0 }
      test "working" do
        Assert.equal (Right { imag: 6.0, real: 4.0 })
          $ addComplexDecodedWorking { real: 1.0, imag: 2.0 } { real: 3.0, imag: 4.0 }
    test "mapSetFoo" do
      Assert.equal (Right (Map.fromFoldable [ (Tuple "Foo" 42), (Tuple "cat" 2), (Tuple "hat" 1) ]))
        $ mapSetFoo (Map.fromFoldable [ (Tuple "cat" 2), (Tuple "hat" 1) ])
