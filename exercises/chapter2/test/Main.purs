module Test.Main where

import Prelude
import Test.MySolutions
import Test.NoPeeking.Solutions  -- Note to reader: Delete this line
import Effect (Effect)
import Euler (answer)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main = do
  runTest do
    suite "Euler - Sum of Multiples" do
      test "below 10" do
        Assert.equal 23 (answer 10)
      test "below 1000" do
        Assert.equal 233168 (answer 1000)
    {-  Move this block comment starting point to enable more tests
Note to reader: Delete this line to expand comment block -}
    suite "diagonal" do
      test "3 4 5" do
        Assert.equal 5.0 (diagonal 3.0 4.0)
      test "5 12 13" do
        Assert.equal 13.0 (diagonal 5.0 12.0)
    suite "circleArea" do
      test "radius 1" do
        Assert.equal 3.141592653589793 (circleArea 1.0)
      test "radius 3" do
        Assert.equal 28.274333882308138 (circleArea 3.0)
    suite "addE" do
      test "1.23" do
        Assert.equal 3.948281828459045 (addE "1.23")
      test "4.56" do
        Assert.equal 7.278281828459045 (addE "4.56")

{- Note to reader: Delete this line to expand comment block
-}
