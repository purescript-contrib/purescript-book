module Test.Main where

import Prelude

import Test.MySolutions

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

-}