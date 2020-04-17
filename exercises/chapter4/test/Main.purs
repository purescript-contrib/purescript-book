module Test.Main where

import Prelude
import Test.Solutions
import Data.Maybe (Maybe(..))
import Data.Path (filename, root)
import Data.Tuple (fst)
import Effect (Effect)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    test "Initial passing test"
      $ Assert.equal true true
    suite "Exercise Group 1" do
      suite "Exercise 1 - Test if integer is even" do
        test "0 is even"
          $ Assert.assert "0"
          $ isEven 0
        test "1 is odd"
          $ Assert.assertFalse "1"
          $ isEven 1
        test "20 is even"
          $ Assert.assert "20"
          $ isEven 20
        test "19 is odd"
          $ Assert.assertFalse "19"
          $ isEven 19
      suite "Exercise 2 - Count even integers in Array" do
        test "[] has none"
          $ Assert.equal 0
          $ evenCount []
        test "[0] has 1"
          $ Assert.equal 1
          $ evenCount [ 0 ]
        test "[1] has 0"
          $ Assert.equal 0
          $ evenCount [ 1 ]
        test "[0, 1, 19, 20] has 2"
          $ Assert.equal 2
          $ evenCount [ 0, 1, 19, 20 ]
    suite "Exercise Group 2" do
      suite "Exercise 1 - Square each Number in an Array" do
        test "Do nothing with empty array"
          $ Assert.equal []
          $ squared []
        test "Calculate squares"
          $ Assert.equal [ 0.0, 1.0, 4.0, 9.0, 10000.0 ]
          $ squared [ 0.0, 1.0, 2.0, 3.0, 100.0 ]
      suite "Exercise 2 - Remove negative numbers in array" do
        test "Do nothing with empty array"
          $ Assert.equal []
          $ keepNonNegative []
        test "Filter negative numbers"
          $ Assert.equal [ 0.0, 2.0, 3.0 ]
          $ keepNonNegative [ -1.5, -1.0, 0.0, -0.1, 2.0, 3.0, -4.0 ]
      suite "Exercise 3 - <$?> operator for filter" do
        test "Define <$?> operator for filter"
          $ Assert.equal [ 1, 1 ]
          $ (_ == 1)
          <$?> [ 1, 2, 3, 1, 2, 3 ]
        test "Rewrite previous filtering solution using new operator"
          $ Assert.equal [ 0.0, 2.0, 3.0 ]
          $ keepNonNegativeRewrite [ -1.5, -1.0, 0.0, -0.1, 2.0, 3.0, -4.0 ]
    suite "Exercise Group 3" do
      suite "Exercise 1 - Identify prime integer" do
        test "0 is not prime"
          $ Assert.assertFalse "prime numbers start at 1"
          $ isPrime 0
        test "1 is prime"
          $ Assert.assert "1"
          $ isPrime 1
        test "4 is not prime"
          $ Assert.assertFalse "all even numbers above 2 are not prime"
          $ isPrime 4
        test "Test for large prime number"
          $ Assert.assert "failed for largest prime number under 1000"
          $ isPrime 997
      suite "Exercise 2 - Cartesian product" do
        test "Left array is empty"
          $ Assert.equal ([] :: Array (Array String))
          $ cartesianProduct [] [ "five" ]
        test "Right array is empty"
          $ Assert.equal ([] :: Array (Array String))
          $ cartesianProduct [ "5" ] []
        test "Two singleton arrays"
          $ Assert.equal [ [ "5", "five" ] ]
          $ cartesianProduct [ "5" ] [ "five" ]
        test "Arrays larger than singletons"
          $ Assert.equal [ [ "5", "five" ], [ "5", "six" ], [ "6", "five" ], [ "6", "six" ] ]
          $ cartesianProduct [ "5", "6" ] [ "five", "six" ]
      suite "Exercise 3 - Pythagorean Triple" do
        test "Pythagorean triple -- single element array result"
          $ Assert.equal [ [ 3, 4, 5 ] ]
          $ triples 5
        test "Pythagorean triple -- multiple element array result"
          $ Assert.equal [ [ 3, 4, 5 ], [ 5, 12, 13 ], [ 6, 8, 10 ] ]
          $ triples 13
      suite "Exercise 4 - factorizations" do
        test "Test small non-prime number"
          $ Assert.equal [ 3, 2 ]
          $ factorizations 6
        test "Test number that uses the prime numbers less than 10"
          $ Assert.equal [ 7, 5, 3, 2 ]
          $ factorizations 210
    suite "Exercise Group 4" do
      suite "Exercise 1 - foldl for true" do
        test "Test when all elements are true"
          $ Assert.assert "one of the elements wasn't true"
          $ allTrue [ true, true, true ]
        test "Test when all the elements are not true"
          $ Assert.assertFalse "One or more of the elements were false"
          $ allTrue [ true, false, true ]
      suite "Exercise 2 - foldl (==) false xs" do
        test "returns true when 1st 2 elements are false, true then trailing trues"
          $ Assert.assert "Failed when 1st element is false and remaining elements are true"
          $ exclusiveOrThenTrue [ false, true, true, true, true, true, true ]
        test "returns true when 1st 2 elements are true, false then trailing trues"
          $ Assert.assert "Failed when 1st element is true, 2nd one false, and remainder are true"
          $ exclusiveOrThenTrue [ true, false, true, true, true, true, true ]
        test "returns true when last element is false"
          $ Assert.assertFalse "Failed when last element is false"
          $ exclusiveOrThenTrue [ true, false, true, true, true, true, true, false ]
      suite "Exercise 3 - Rewrite fib in tail recursion" do
        test "Verify 0"
          $ Assert.equal 1
          $ fib 0
        test "Verify 1"
          $ Assert.equal 1
          $ fib 1
        test "Verify 2"
          $ Assert.equal 2
          $ fib 2
        test "Verify 5"
          $ Assert.equal 8
          $ fib 5
        test "Verify 7"
          $ Assert.equal 21
          $ fib 7
        test "Verify 9"
          $ Assert.equal 55
          $ fib 9
        test "Verify 44"
          $ Assert.equal 1134903170
          $ fib 44
      suite "Exercise 4: reverse in terms of foldl" do
        test "Empty Array"
          $ Assert.equal ([] :: Array Int)
          $ reverse []
        test "Singleton Array"
          $ Assert.equal [ 1 ]
          $ reverse [ 1 ]
        test "More than 1 element"
          $ Assert.equal [ 3, 2, 1 ]
          $ reverse [ 1, 2, 3 ]
    suite "Exercise Group 5" do
      suite "Exercise 1: onlyFiles" do
        test "all files under root"
          $ Assert.equal
              [ "/bin/cp"
              , "/bin/ls"
              , "/bin/mv"
              , "/etc/hosts"
              , "/home/user/todo.txt"
              , "/home/user/code/js/test.js"
              , "/home/user/code/haskell/test.hs"
              ]
          $ map filename
          $ onlyFiles root
      suite "Exercise 2: find largest and smallest files" do
        test "largestSmallest for root"
          $ Assert.equal [ "/home/user/code/js/test.js", "/etc/hosts" ]
          $ map fst
          $ largestSmallest root
      suite "Exercise 3: whereIs" do
        test "locates a file"
          $ Assert.equal (Just ("/bin/"))
          $ whereIs "ls"
        test "doesn't locate a file"
          $ Assert.equal (Nothing)
          $ whereIs "lss"
