module Test.Main where

import Prelude
import Test.Examples
import Test.MySolutions
import Data.Array (sort)
import Data.Maybe (Maybe(..))
import Data.Path (Path(..), filename, root)
import Data.Tuple (fst)
import Effect (Effect)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert (assert, assertFalse)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    runChapterExamples
    {-  Move this block comment starting point to enable more tests
    suite "Exercise Group - Recursion" do
      test "Exercise - isEven" do
        assert "0 is even"
          $ isEven 0
        assertFalse "1 is odd"
          $ isEven 1
        assert "20 is even"
          $ isEven 20
        assertFalse "19 is odd"
          $ isEven 19
      suite "Exercise - countEven" do
        test "[] has none" do
          Assert.equal 0
            $ countEven []
        test "[0] has 1" do
          Assert.equal 1
            $ countEven [ 0 ]
        test "[1] has 0" do
          Assert.equal 0
            $ countEven [ 1 ]
        test "[0, 1, 19, 20] has 2" do
          Assert.equal 2
            $ countEven [ 0, 1, 19, 20 ]
    suite "Exercise Group - Maps, Infix Operators, and Filtering" do
      suite "Exercise - squared" do
        test "Do nothing with empty array" do
          Assert.equal []
            $ squared []
        test "Calculate squares" do
          Assert.equal [ 0.0, 1.0, 4.0, 9.0, 10000.0 ]
            $ squared [ 0.0, 1.0, 2.0, 3.0, 100.0 ]
      suite "Exercise - keepNonNegative" do
        test "Do nothing with empty array" do
          Assert.equal []
            $ keepNonNegative []
        test "Filter negative numbers" do
          Assert.equal [ 0.0, 2.0, 3.0 ]
            $ keepNonNegative [ -1.5, -1.0, 0.0, -0.1, 2.0, 3.0, -4.0 ]
      suite "Exercise - <$?> infix operator for filter" do
        test "Define <$?> operator for filter" do
          Assert.equal [ 1, 1 ]
            $ (_ == 1)
            <$?> [ 1, 2, 3, 1, 2, 3 ]
        test "keepNonNegativeRewrite " do
          Assert.equal [ 0.0, 2.0, 3.0 ]
            $ keepNonNegativeRewrite [ -1.5, -1.0, 0.0, -0.1, 2.0, 3.0, -4.0 ]
    suite "Exercise Group - Flattening, Comprehensions, Do Notation, and Guards" do
      test "Exercise - isPrime" do
        assertFalse "0 is not prime"
          $ isPrime 0
        assertFalse "1 is not prime"
          $ isPrime 1
        assert "2 is prime"
          $ isPrime 2
        assertFalse "4 is not prime"
          $ isPrime 4
        assert "997 is prime"
          $ isPrime 997
      suite "Exercise - cartesianProduct" do
        let
          -- Don't worry if this this testing helper function signature looks confusing.
          -- It will make more sense after chapter 6
          testcp :: forall a. Eq a => Show a => Ord a => String -> Array (Array a) -> Array a -> Array a -> TestSuite
          testcp label expected arr1 arr2 =
            test label do
              -- Sorting to allow any ordering
              Assert.equal (sort expected)
                $ sort
                $ cartesianProduct arr1 arr2
        testcp "Left array is empty" [] [] [ "five" ]
        testcp "Right array is empty" [] [ "5" ] []
        testcp "Two singleton arrays"
          [ [ "5", "five" ] ]
          [ "5" ]
          [ "five" ]
        testcp "Arrays larger than singletons"
          [ [ "5", "five" ], [ "5", "six" ], [ "6", "five" ], [ "6", "six" ] ]
          [ "5", "6" ]
          [ "five", "six" ]
      suite "Exercise - triples" do
        -- Sorting to allow for any ordering
        test "single element array result" do
          Assert.equal (sort [ [ 3, 4, 5 ] ])
            $ sort
            $ triples 5
        test "multiple element array result" do
          Assert.equal (sort [ [ 3, 4, 5 ], [ 5, 12, 13 ], [ 6, 8, 10 ] ])
            $ sort
            $ triples 13
      suite "Exercise - factorize" do
        test "Test small non-prime number" do
          Assert.equal [ 3, 2 ]
            $ factorize 6
        test "Test number that uses the prime numbers less than 10" do
          Assert.equal [ 7, 5, 3, 2 ]
            $ factorize 210
    suite "Exercise Group - Folds and Tail Recursion" do
      test "Exercise - allTrue" do
        assert "all elements true"
          $ allTrue [ true, true, true ]
        assertFalse "some elements false"
          $ allTrue [ true, false, true ]
      suite "Exercise - fibTailRec" do
        test "Verify 0" do
          Assert.equal 1
            $ fibTailRec 0
        test "Verify 9" do
          Assert.equal 55
            $ fibTailRec 9
        test "Verify 44" do
          Assert.equal 1134903170
            $ fibTailRec 44
      suite "Exercise - reverse" do
        test "Empty Array" do
          Assert.equal ([] :: Array Int)
            $ reverse []
        test "Singleton Array" do
          Assert.equal [ 1 ]
            $ reverse [ 1 ]
        test "More than 1 element" do
          Assert.equal [ 3, 2, 1 ]
            $ reverse [ 1, 2, 3 ]
    suite "Exercise Group - Filesystem" do
      test "Exercise - onlyFiles" do
        Assert.equal
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
      suite "Exercise - whereIs" do
        test "locates a file"
          $ Assert.equal (Just ("/bin/"))
          $ map filename
          $ whereIs root "ls"
        test "doesn't locate a file"
          $ Assert.equal (Nothing)
          $ map filename
          $ whereIs root "cat"
      suite "Exercise - largestSmallest" do
        let
          testls :: String -> Array String -> Path -> TestSuite
          testls label expected path =
            test label do
              Assert.equal expected
              -- Sorting to allow any ordering
                $ sort
                $ map filename
                $ largestSmallest path
          oneFileDir = Directory "/etc/" [ File "/etc/hosts" 300 ]
          emptyDir = Directory "/etc/" []
        testls "works for root" ["/etc/hosts", "/home/user/code/js/test.js"] root
        testls "works for a directory with one file" ["/etc/hosts"] oneFileDir
        testls "works for an empty directory" [] emptyDir

-}
runChapterExamples :: TestSuite
runChapterExamples =
  suite "Chapter Examples" do
    test "fact" do
      Assert.equal 120
        $ fact 5
    test "fib" do
      Assert.equal 55
        $ fib 9
    test "length" do
      Assert.equal 3
        $ length [ 0, 0, 0 ]
    test "factors" do
      Assert.equal [ [ 1, 10 ], [ 2, 5 ] ]
        $ factors 10
    test "factorsV2" do
      Assert.equal [ [ 1, 10 ], [ 2, 5 ] ]
        $ factorsV2 10
    test "factorsV3" do
      Assert.equal [ [ 1, 10 ], [ 2, 5 ] ]
        $ factorsV3 10
    test "factTailRec" do
      Assert.equal 120
        $ factTailRec 5 1
    test "lengthTailRec" do
      Assert.equal 3
        $ lengthTailRec [ 0, 0, 0 ]
    test "allFiles" do
      Assert.equal allFileAndDirectoryNames
        $ filename
        <$> allFiles root
    test "allFiles'" do
      Assert.equal allFileAndDirectoryNames
        $ filename
        <$> allFiles' root

allFileAndDirectoryNames :: Array (String)
allFileAndDirectoryNames =
  [ "/"
  , "/bin/"
  , "/bin/cp"
  , "/bin/ls"
  , "/bin/mv"
  , "/etc/"
  , "/etc/hosts"
  , "/home/"
  , "/home/user/"
  , "/home/user/todo.txt"
  , "/home/user/code/"
  , "/home/user/code/js/"
  , "/home/user/code/js/test.js"
  , "/home/user/code/haskell/"
  , "/home/user/code/haskell/test.hs"
  ]
