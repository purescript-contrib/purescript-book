module Test.Main where

import Prelude
import Test.MySolutions
import Test.NoPeeking.Solutions

import Data.Int(round)
import Data.Maybe(Maybe(Just, Nothing))
import Data.Person (Person)
import Data.Picture (Point(..), Shape(..), Picture, Bounds(..), getCenter, origin)
import Effect (Effect)
import Test.Unit (suite, test)
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
  [ (Circle origin 2.0)
  , (Circle (Point { x: 2.0, y: 2.0 }) 3.0)
  , (Rectangle (Point { x: 5.0, y: 5.0 }) 4.0 4.0)
  ]

main :: Effect Unit
main =
  runTest do
    {-  Move this block comment starting point to enable more tests
Note to reader: Delete this line to expand comment block -}
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
          $ doubleScaleAndCenter $ Circle (Point { x: 2.0, y: 2.0 }) 5.0
        Assert.equal (Rectangle origin 10.0 10.0)
          $ doubleScaleAndCenter $ Rectangle (Point { x: 0.0, y: 0.0 }) 5.0 5.0
        Assert.equal (Rectangle origin 40.0 40.0)
          $ doubleScaleAndCenter $ Rectangle (Point { x: 30.0, y: 30.0 }) 20.0 20.0
        Assert.equal (Line (Point { x: -4.0, y: -4.0 }) (Point { x: 4.0, y: 4.0 }))
          $ doubleScaleAndCenter $ Line (Point { x: -2.0, y: -2.0 }) (Point { x: 2.0, y: 2.0 })
        Assert.equal (Line (Point { x: -4.0, y: -4.0 }) (Point { x: 4.0, y: 4.0 }))
          $ doubleScaleAndCenter $ Line (Point { x: 0.0, y: 4.0 }) (Point { x: 4.0, y: 8.0 })
        Assert.equal (Text (Point { x: 0.0, y: 0.0 }) "Hello .purs!" )
          $ doubleScaleAndCenter $ Text (Point { x: 4.0, y: 6.0 }) "Hello .purs!"
      test "Exercise - shapeText" do
        Assert.equal (Just "Hello .purs!")
          $ shapeText $ Text origin "Hello .purs!"
        Assert.equal Nothing
          $ shapeText $ Circle origin 1.0
        Assert.equal Nothing
          $ shapeText $ Rectangle origin 1.0 1.0
        Assert.equal Nothing
          $ shapeText $ Line origin (Point { x: 1.0, y: 1.0 })
    suite "Exercise Group - Vector Graphics" do
      test "Exercise - area" do
        Assert.equal 50
          $ round $ area $ Circle origin 4.0
        Assert.equal 40
          $ round $ area $ Rectangle origin 4.0 10.0
        Assert.equal 0
          $ round $ area $ Line origin (Point { x: 2.0, y: 2.0 })
        Assert.equal 0
          $ round $ area $ Text origin "Text has no area!"
      test "Exercise - Clipped shapeBounds" do
        Assert.equal (Bounds { top: -2.0, left: -2.0, right: 2.0, bottom: 2.0 })
          $ shapeBounds (Clipped samplePicture (Point { x: 0.0, y: 0.0 }) 4.0 4.0)
        Assert.equal (Bounds { top: 3.0, left: 3.0, right: 7.0, bottom: 7.0 })
          $ shapeBounds (Clipped samplePicture (Point { x: 5.0, y: 5.0 }) 4.0 4.0)
    {- Note to reader: Delete this line to expand comment block
    -}
