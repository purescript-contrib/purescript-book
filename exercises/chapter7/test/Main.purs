module Test.Main where

import Prelude
import Test.Solutions
import Control.Monad.Writer (runWriter, tell)
import Data.AddressBook (PhoneType(..), address, phoneNumber)
import Data.Array ((..))
import Data.Either (Either(..))
import Data.Int (fromNumber)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.String.Regex as R
import Data.Traversable (traverse)
import Data.Tuple (snd)
import Data.Validation.Semigroup (invalid)
import Effect (Effect)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    test "Dummy test" do
      Assert.equal true true

{-  Move this block comment starting point to enable more tests
    suite "Exercise Group 1" do
      suite "Exercise - Numeric operators that work with Maybe" do
        suite "addMaybe" do
          test "Just" do
            Assert.equal (Just 7)
              $ addMaybe (Just 5) (Just 2)
          test "Nothing on left" do
            Assert.equal Nothing
              $ addMaybe Nothing (Just 2)
          test "Nothing on right" do
            Assert.equal Nothing
              $ addMaybe (Just 5) Nothing
        test "subMaybe" do
          Assert.equal (Just 3)
            $ subMaybe (Just 5) (Just 2)
        test "mulMaybe" do
          Assert.equal (Just 10)
            $ mulMaybe (Just 5) (Just 2)
        test "divMaybe" do
          Assert.equal (Just 2)
            $ divMaybe (Just 5) (Just 2)
      suite "Exercise - Numeric operators that work with Apply" do
        suite "addApply" do
          test "Maybe Just" do
            Assert.equal (Just 7)
              $ addApply (Just 5) (Just 2)
          test "Maybe Nothing" do
            Assert.equal Nothing
              $ addApply (Just 5) Nothing
          test "Either Right" do
            Assert.equal (Right 7 :: Either String Int)
              $ addApply (Right 5) (Right 2)
          test "Either Left" do
            Assert.equal (Left "fail" :: Either String Int)
              $ addApply (Right 5) (Left "fail")
        suite "subApply" do
          test "Maybe" do
            Assert.equal (Just 3)
              $ subApply (Just 5) (Just 2)
          test "Either" do
            Assert.equal (Right 3 :: Either String Int)
              $ subApply (Right 5) (Right 2)
        suite "mulApply" do
          test "Maybe" do
            Assert.equal (Just 10)
              $ mulApply (Just 5) (Just 2)
          test "Either" do
            Assert.equal (Right 10 :: Either String Int)
              $ mulApply (Right 5) (Right 2)
        suite "divApply" do
          test "Maybe" do
            Assert.equal (Just 2)
              $ divApply (Just 5) (Just 2)
          test "Either" do
            Assert.equal (Right 2 :: Either String Int)
              $ divApply (Right 5) (Right 2)
      suite "Exercise - combineMaybe" do
        suite "Array Int" do
          test "Just" do
            Assert.equal ([ Just 1, Just 2, Just 3 ])
              $ combineMaybe (Just $ [ 1, 2, 3 ])
          test "Nothing" do
            Assert.equal ([ Nothing ])
              $ combineMaybe (Nothing :: Maybe (Array Int))
        suite "List Char" do
          test "Just"
            $ Assert.equal (Just 'a' : Just 'b' : Just 'c' : Nil)
            $ combineMaybe (Just $ 'a' : 'b' : 'c' : Nil)
          test "Nothing"
            $ Assert.equal (Nothing : Nil)
            $ combineMaybe (Nothing :: Maybe (List Char))
    suite "Exercise Group 2" do
      suite "Exercise - stateRegex" do
        let
          stateTest str exp =
            test (show str) do
              Assert.equal exp
                $ R.test stateRegex str
        stateTest "CA" true
        stateTest "Ca" true
        stateTest "C" false
        stateTest "CAA" false
        stateTest "C3" false
      suite "Exercise - nonEmptyRegex" do
        let
          nonEmptyTest str exp =
            test (show str) do
              Assert.equal exp
                $ R.test nonEmptyRegex str
        nonEmptyTest "Houston" true
        nonEmptyTest "My Street" true
        nonEmptyTest "Ñóñá" true
        nonEmptyTest "" false
        nonEmptyTest " " false
        nonEmptyTest "\t" false
      suite "Exercise - validateAddressImproved" do
        test "Valid" do
          let
            addr = address "22 Fake St" "Fake City" "CA"
          Assert.equal (pure addr)
            $ validateAddressImproved addr
        test "Invalid Street" do
          Assert.equal (invalid [ "Field 'Street' did not match the required format" ])
            $ validateAddressImproved
            $ address "" "Fake City" "CA"
        test "Invalid City" do
          Assert.equal (invalid [ "Field 'City' did not match the required format" ])
            $ validateAddressImproved
            $ address "22 Fake St" "\t" "CA"
        test "Invalid State" do
          Assert.equal (invalid [ "Field 'State' did not match the required format" ])
            $ validateAddressImproved
            $ address "22 Fake St" "Fake City" "C3"
    suite "Exercise Group 3" do
      suite "Exercise - Tree Show and Eq" do
        let
          tree :: Tree Int
          tree = Branch (Branch Leaf 1 Leaf) 2 (Branch Leaf 3 Leaf)
        test "Show" do
          Assert.equal "(Branch (Branch Leaf 1 Leaf) 2 (Branch Leaf 3 Leaf))"
            $ show tree
        test "Eq - Equal" do
          Assert.equal tree tree
        test "Eq - Not Equal" do
          Assert.expectFailure "not equal"
            $ Assert.equal tree Leaf
      let
        leaf :: forall a. a -> Tree a
        leaf x = Branch Leaf x Leaf
      suite "Exercise - traverse" do
        suite "Maybe side-effect" do
          test "Just" do
            Assert.equal (Just $ Branch (leaf 1) 2 (leaf 3))
              $ traverse fromNumber
              $ Branch (leaf 1.0) 2.0 (leaf 3.0)
          test "Nothing"
            $ Assert.equal Nothing
            $ traverse fromNumber
            $ Branch (leaf 1.0) 2.0 (leaf 3.7)
        test "Array side-effect - check traversal order" do
          Assert.equal (1 .. 7)
            $ snd
            $ runWriter
            $ traverse (\x -> tell [ x ])
            $ Branch (Branch (leaf 1) 2 (leaf 3)) 4 (Branch (leaf 5) 6 (leaf 7))
      test "Exercise - traversePreOrder" do
        Assert.equal (1 .. 7)
          $ snd
          $ runWriter
          $ traversePreOrder (\x -> tell [ x ])
          $ Branch (Branch (leaf 3) 2 (leaf 4)) 1 (Branch (leaf 6) 5 (leaf 7))
      test "Exercise - traversePostOrder" do
        Assert.equal (1 .. 7)
          $ snd
          $ runWriter
          $ traversePostOrder (\x -> tell [ x ])
          $ Branch (Branch (leaf 1) 3 (leaf 2)) 7 (Branch (leaf 4) 6 (leaf 5))
      suite "Exercise - validatePersonOptionalAddress" do
        let
          examplePerson =
            { firstName: "John"
            , lastName: "Smith"
            , homeAddress: Just $ address "123 Fake St." "FakeTown" "CA"
            , phones:
                [ phoneNumber HomePhone "555-555-5555"
                , phoneNumber CellPhone "555-555-0000"
                ]
            }
        test "Just Address" do
          Assert.equal (pure examplePerson)
            $ validatePersonOptionalAddress examplePerson
        test "Nothing" do
          let
            examplePersonNoAddress = examplePerson { homeAddress = Nothing }
          Assert.equal (pure examplePersonNoAddress)
            $ validatePersonOptionalAddress examplePersonNoAddress
        test "Just Address with empty city" do
          Assert.equal (invalid ([ "Field 'City' cannot be empty" ]))
            $ validatePersonOptionalAddress
            $ examplePerson { homeAddress = (Just $ address "123 Fake St." "" "CA") }
      suite "Exercise - sequenceUsingTraverse" do
        test "Just"
          $ Assert.equal (Just [ 1, 2 ])
          $ sequenceUsingTraverse [ Just 1, Just 2 ]
        test "Nothing"
          $ Assert.equal Nothing
          $ sequenceUsingTraverse [ Just 1, Nothing ]
      suite "Exercise - traverseUsingSequence" do
        test "Just"
          $ Assert.equal (Just [ 1, 2 ])
          $ traverseUsingSequence fromNumber [ 1.0, 2.0 ]
        test "Nothing"
          $ Assert.equal Nothing
          $ traverseUsingSequence fromNumber [ 1.0, 2.7 ]
-}
