module Test.Main where

import Prelude (Unit, discard, ($), (<>))

import Test.MySolutions
import Test.NoPeeking.Solutions  -- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.

import Effect (Effect)
import Control.Monad.Writer (runWriterT, execWriter)
import Control.Monad.Except (runExceptT)
import Control.Monad.State (runStateT)
import Data.Either (Either(..))
import Data.Monoid.Additive (Additive(..))
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Test.Unit (TestSuite, success, suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    test "" success
    {-  Move this block comment starting point to enable more tests
This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions. -}
    suite "Exercises Group - The State Monad" do
      suite "testParens" do
        let
          runTestParens :: Boolean -> String -> TestSuite
          runTestParens expected str =
            test testName do
              Assert.equal expected $ testParens str
            where testName = "str = \"" <> str <> "\""
        runTestParens true ""
        runTestParens true "(()(())())"
        runTestParens true "(hello)"
        runTestParens false ")"
        runTestParens false "(()()"
        runTestParens false ")("
    suite "Exercises Group - The Reader Monad" do
      suite "indents" do
        let
          expectedText =
            "Here is some indented text:\n\
            \  I am indented\n\
            \  So am I\n\
            \    I am even more indented"
        test "should render with indentations" do
          Assert.equal expectedText
            $ render $ cat
              [ line "Here is some indented text:"
              , indent $ cat
                [ line "I am indented"
                , line "So am I"
                , indent $ line "I am even more indented"
                ]
              ]
    suite "Exercises Group - The Writer Monad" do
      suite "sumArrayWriter" do
        test "should sum arrays" do
          Assert.equal (Additive 21)
            $ execWriter $ do
              sumArrayWriter [1, 2, 3]
              sumArrayWriter [4, 5]
              sumArrayWriter [6]
      suite "collatz" do
        let
          expected_11 =
            Tuple 14 [11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
          expected_15 =
            Tuple 17 [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
        test "c = 11" do
          Assert.equal expected_11
            $ collatz 11
        test "c = 15" do
          Assert.equal expected_15
            $ collatz 15
    suite "Exercises Group - Monad Transformers" do
      suite "parser" do
        let
          runParser p s = unwrap $ runExceptT $ runWriterT $ runStateT p s
        test "should parse a string" do
          Assert.equal (Right (Tuple (Tuple "abc" "def") ["The state is abcdef"]))
            $ runParser (string "abc") "abcdef"
        test "should fail if string could not be parsed" do
          Assert.equal (Left ["Could not parse"])
            $ runParser (string "abc") "foobar"
      suite "indents with ReaderT and WriterT" do
        let
          expectedText =
            "Here is some indented text:\n\
            \  I am indented\n\
            \  So am I\n\
            \    I am even more indented"
        test "should render with indentations" do
          Assert.equal expectedText
            $ render' $ do
                line' "Here is some indented text:"
                indent' $ do
                  line' "I am indented"
                  line' "So am I"
                  indent' $ do
                    line' "I am even more indented"

    suite "Exercises Group - Monad Comprehensions/backtracking" do
      suite "parser" do
        let
          runParser p s = unwrap $ runExceptT $ runWriterT $ runStateT p s
        test "should parse as followed by bs" do
          Assert.equal (Right (Tuple (Tuple "aaabb" "cde") [
            "The state is aaabbcde",
            "The state is aabbcde",
            "The state is abbcde",
            "The state is bbcde",
            "The state is bcde"]))
            $ runParser asFollowedByBs "aaabbcde"
        test "should fail if first is not a" do
          Assert.equal (Left ["Could not parse"])
            $ runParser asFollowedByBs "bfoobar"
        test "should parse as and bs" do
          Assert.equal (Right (Tuple (Tuple "babbaa" "cde") [
            "The state is babbaacde",
            "The state is abbaacde",
            "The state is bbaacde",
            "The state is baacde",
            "The state is aacde",
            "The state is acde"]))
            $ runParser asOrBs "babbaacde"
        test "should fail if first is not a or b" do
          Assert.equal (Left ["Could not parse","Could not parse"])
            $ runParser asOrBs "foobar"
{- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions.
-}