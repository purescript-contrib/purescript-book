module Test.Main where

import Prelude hiding (gcd)
import Test.MySolutions
import Test.NoPeeking.Solutions  -- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.

import ChapterExamples (Amp(..), current, fromString, gcd, gcdV2, isEmpty, livesInLA, lzs, partialFunction, showPerson, showPersonV2, sortPair, takeFive, toString, unknownPerson, Volt(..))
import Data.Int (round)
import Data.Maybe (Maybe(Just, Nothing))
import Data.Person (Person)
import Data.Picture (Shape(..), Picture, getCenter, origin)
import Effect (Effect)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

john :: Person
john = { name: "John Smith", address: { street: "123 Test Lane", city: "Los Angeles" } }

rose :: Person
rose = { name: "Rose Jackson", address: { street: "464 Sample Terrace", city: "Los Angeles" } }

amy :: Person
amy = { name: "Amy Lopez", address: { street: "10 Purs Street", city: "Omaha" } }

samplePicture :: Picture
samplePicture =
  [ Circle origin 2.0
  , Circle { x: 2.0, y: 2.0 } 3.0
  , Rectangle { x: 5.0, y: 5.0 } 4.0 4.0
  ]

main :: Effect Unit
main =
  runTest do
    runChapterExamples
    {-  Move this block comment starting point to enable more tests
This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions. -}
    suite "Exercise Group - Simple Pattern Matching" do
      test "Exercise - factorial" do
        Assert.equal 1
          $ factorial 0
        Assert.equal 1
          $ factorial 1
        Assert.equal 24
          $ factorial 4
        Assert.equal 3628800
          $ factorial 10
      test "Exercise - binomial" do
        Assert.equal 1
          $ binomial 10 0
        Assert.equal 0
          $ binomial 0 3
        Assert.equal 0
          $ binomial 2 5
        Assert.equal 252
          $ binomial 10 5
        Assert.equal 1
          $ binomial 5 5
      test "Exercise - pascal" do
        Assert.equal 1
          $ pascal 10 0
        Assert.equal 0
          $ pascal 0 3
        Assert.equal 0
          $ pascal 2 5
        Assert.equal 252
          $ pascal 10 5
        Assert.equal 1
          $ pascal 5 5
    suite "Exercise Group - Array and Record Patterns" do
      test "Exercise - sameCity" do
        Assert.equal true
          $ sameCity john rose
        Assert.equal false
          $ sameCity amy rose
      test "Exercise - fromSingleton" do
        Assert.equal "default"
          $ fromSingleton "default" []
        Assert.equal "B"
          $ fromSingleton "default" ["B"]
        Assert.equal "default"
          $ fromSingleton "default" ["B", "C", "D"]
    suite "Exercise Group - Algebraic Data Types" do
      test "Exercise - circleAtOrigin" do
        Assert.equal origin
          $ getCenter circleAtOrigin
      test "Exercise - doubleScaleAndCenter" do
        Assert.equal (Circle origin 10.0)
          $ doubleScaleAndCenter $ Circle origin 5.0
        Assert.equal (Circle origin 10.0)
          $ doubleScaleAndCenter $ Circle { x: 2.0, y: 2.0 } 5.0
        Assert.equal (Rectangle origin 10.0 10.0)
          $ doubleScaleAndCenter $ Rectangle { x: 0.0, y: 0.0 } 5.0 5.0
        Assert.equal (Rectangle origin 40.0 40.0)
          $ doubleScaleAndCenter $ Rectangle { x: 30.0, y: 30.0 } 20.0 20.0
        Assert.equal (Line { x: -4.0, y: -4.0 } { x: 4.0, y: 4.0 })
          $ doubleScaleAndCenter $ Line { x: -2.0, y: -2.0 } { x: 2.0, y: 2.0 }
        Assert.equal (Line { x: -4.0, y: -4.0 } { x: 4.0, y: 4.0 })
          $ doubleScaleAndCenter $ Line { x: 0.0, y: 4.0 } { x: 4.0, y: 8.0 }
        Assert.equal (Text { x: 0.0, y: 0.0 } "Hello .purs!" )
          $ doubleScaleAndCenter $ Text { x: 4.0, y: 6.0 } "Hello .purs!"
      test "Exercise - shapeText" do
        Assert.equal (Just "Hello .purs!")
          $ shapeText $ Text origin "Hello .purs!"
        Assert.equal Nothing
          $ shapeText $ Circle origin 1.0
        Assert.equal Nothing
          $ shapeText $ Rectangle origin 1.0 1.0
        Assert.equal Nothing
          $ shapeText $ Line origin { x: 1.0, y: 1.0 }
    suite "Exercise Group - Newtype" do
      test "Exercise - calculateWattage" do
        Assert.equal 60.0
          $ let (Watt w) = calculateWattage (Amp 0.5) (Volt 120.0)
            in w
    suite "Exercise Group - Vector Graphics" do
      test "Exercise - area" do
        Assert.equal 50
          $ round $ area $ Circle origin 4.0
        Assert.equal 40
          $ round $ area $ Rectangle origin 4.0 10.0
        Assert.equal 0
          $ round $ area $ Line origin { x: 2.0, y: 2.0 }
        Assert.equal 0
          $ round $ area $ Text origin "Text has no area!"
      test "Exercise - Clipped shapeBounds" do
        Assert.equal { top: -2.0, left: -2.0, right: 2.0, bottom: 2.0 }
          -- Note to users: You'll need to manually import shapeBounds
          -- from Data.Picture. Don't import from Test.NoPeeking.Solutions.
          $ shapeBounds (Clipped samplePicture { x: 0.0, y: 0.0 } 4.0 4.0)
        Assert.equal { top: 3.0, left: 3.0, right: 7.0, bottom: 7.0 }
          $ shapeBounds (Clipped samplePicture { x: 5.0, y: 5.0 } 4.0 4.0)
        Assert.equal { top: 2.0, left: 2.0, right: 7.0, bottom: 7.0 }
          $ shapeBounds (Clipped samplePicture { x: 5.0, y: 5.0 } 6.0 6.0)

{- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.
-}
runChapterExamples :: TestSuite
runChapterExamples =
  suite "Chapter Examples" do
    test "gcd" do
      Assert.equal 20
        $ gcd 60 100
    test "fromString" do
      Assert.equal true
        $ fromString "true"
    test "toString" do
      Assert.equal "false"
        $ toString false
    test "gcdV2" do
      Assert.equal 20
        $ gcdV2 60 100
    test "isEmpty" do
      Assert.equal false
        $ isEmpty [2, 3]
    test "takeFive" do
      Assert.equal 6
        $ takeFive [0, 1, 2, 3, 4]
    test "showPerson" do
      Assert.equal "Lovelace, Ada"
        $ showPerson {first: "Ada", last: "Lovelace"}
    test "showPersonV2" do
      Assert.equal "Lovelace, Ada"
        $ showPersonV2 {first: "Ada", last: "Lovelace"}
    test "unknownPerson" do
      Assert.equal {first: "Jane", last: "Doe"} unknownPerson
    test "livesInLA" do
      Assert.equal true
        $ livesInLA {name: "Suraj", address: {street: "123 Main St", city: "Los Angeles"}}
    test "sortPair" do
      Assert.equal [1, 2]
        $ sortPair [2, 1]
    test "lzs" do
      Assert.equal [-1, -2, 3]
        $ lzs [1, -1, -2, 3]
    test "partialFunction" do
      Assert.equal true
        $ partialFunction true
    test "current" do
      Assert.equal (Amp 0.003) current
