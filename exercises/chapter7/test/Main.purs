module Test.Main where

import Prelude
import Effect (Effect)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    suite "Verify unit tests are set up" do
      test "true eq true"
        $ Assert.equal true
        $ true

{-  Move this block comment starting point to enable more tests
    suite "Exercise Group 1" do
      suite "Exercise 1: Use lift2 to write lifted versions of numeric operators" do
        test "+ (Just)"
          $ Assert.equal (Just 5)
          $ (+)
          <$> (Just 2)
          <*> (Just 3)
        test "+ (Nothing on left)"
          $ Assert.equal Nothing
          $ (+)
          <$> Nothing
          <*> (Just 3)
        test "+ (Nothing on right)"
          $ Assert.equal Nothing
          $ (+)
          <$> (Just 2)
          <*> Nothing
        test "- (Just)"
          $ Assert.equal (Just (-1))
          $ (-)
          <$> (Just 2)
          <*> (Just 3)
        test "- (Nothing on left)"
          $ Assert.equal Nothing
          $ (-)
          <$> Nothing
          <*> (Just 3)
        test "- (Nothing on right)"
          $ Assert.equal Nothing
          $ (-)
          <$> (Just 2)
          <*> Nothing
        test "* (Just)"
          $ Assert.equal (Just 6)
          $ (*)
          <$> (Just 2)
          <*> (Just 3)
        test "* (Nothing on left)"
          $ Assert.equal Nothing
          $ (*)
          <$> Nothing
          <*> (Just 3)
        test "* (Nothing on right)"
          $ Assert.equal Nothing
          $ (*)
          <$> (Just 2)
          <*> Nothing
        test "/ (Just)"
          $ Assert.equal (Just 2)
          $ (/)
          <$> (Just 6)
          <*> (Just 3)
        test "/ (Nothing on left)"
          $ Assert.equal Nothing
          $ (/)
          <$> Nothing
          <*> (Just 3)
        test "/ (Nothing on right)"
          $ Assert.equal Nothing
          $ (/)
          <$> (Just 2)
          <*> Nothing
      suite "Convince yourself that the definition of lift3 type checks" do
        test "Substituting an Integer type for any of the strings fails to compile"
          $ Assert.assert "Manually compiled and manually verifed compiling failed"
          $ true
      suite "Write a function combineMaybe" do
        suite "Applicative Array Int" do
          test "Just"
            $ Assert.equal ([ Just 1, Just 2, Just 3 ])
            $ combineMaybe (Just $ [ 1, 2, 3 ])
          test "Nothing"
            $ Assert.equal ([ Nothing ])
            $ combineMaybe (Nothing :: Maybe (Array Int))
        suite "Applicative List Char" do
          test "Just"
            $ Assert.equal (Just 'a' : Just 'b' : Just 'c' : Nil)
            $ combineMaybe (Just $ 'a' : 'b' : 'c' : Nil)
          test "Nothing"
            $ Assert.equal (Nothing : Nil)
            $ combineMaybe (Nothing :: Maybe (List Char))
    suite "Exercise Group 2" do
      let
        addr = address "22 Fake St" "Fake City" "CA"
      suite "Regex validator for state code to be two all-caps letters" do
        test "Passes validation" do
          Assert.equal (pure addr)
            $ validateAddressRegex addr
        suite "Fails validation" do
          let
            fail = invalid ([ "Field 'State' did not match the required format" ])
          test "Too few letters"
            $ Assert.equal fail
            $ validateAddressRegex (address "22 Fake St" "Fake City" "C")
          test "Too many letters"
            $ Assert.equal fail
            $ validateAddressRegex (address "22 Fake St" "Fake City" "CAA")
          test "Contains non-letters"
            $ Assert.equal fail
            $ validateAddressRegex (address "22 Fake St" "Fake City" "C3")
          test "Not all caps"
            $ Assert.equal fail
            $ validateAddressRegex (address "22 Fake St" "Fake City" "Ca")
      suite "Regex validator to not allow only whitespace" do
        test "Passes validation with no leading or trailing whitespace" do
          Assert.equal (pure addr)
            $ validateAddressRegex' addr
        suite "Passes validation with leading and trailing whitespace" do
          let
            addr' = address "22 Fake St" " Fake City " "CA"
          test "Leading and trailing whitespace"
            $ Assert.equal (pure addr')
            $ validateAddressRegex' addr'
        suite "Fails validation" do
          let
            fail = invalid ([ "Field 'City' did not match the required format" ])
          test "Empty string"
            $ Assert.equal fail
            $ validateAddressRegex' (address "22 Fake St" "" "CA")
          test "One space character"
            $ Assert.equal fail
            $ validateAddressRegex' (address "22 Fake St" " " "CA")
          test "One tab character"
            $ Assert.equal fail
            $ validateAddressRegex' (address "22 Fake St" "\t" "CA")
    suite "Exercise Group 3" do
      suite "Exercise 1 - Write a Traversable instance for a binary tree structure" do
        test "TODO - 'empty' test which passes"
          $ Assert.equal true
          $ true
      suite "Exercise 2 - Verify possible maybe for person's address field" do
        test "Just Address" do
          let
            examplePerson =
              person' "John" "Smith"
                (Just $ address "123 Fake St." "FakeTown" "CA")
                [ phoneNumber HomePhone "555-555-5555"
                , phoneNumber CellPhone "555-555-0000"
                ]
          Assert.equal (pure examplePerson)
            $ validatePersonWithMaybeAddress examplePerson
        test "Nothing" do
          let
            examplePerson =
              person' "John" "Smith"
                Nothing
                [ phoneNumber HomePhone "555-555-5555"
                , phoneNumber CellPhone "555-555-0000"
                ]
          Assert.equal (pure examplePerson)
            $ validatePersonWithMaybeAddress examplePerson
        test "'Just Address' when city is empty" do
          Assert.equal (invalid ([ "Field 'City' cannot be empty" ]))
            $ validatePersonWithMaybeAddress
            $ person' "John" "Smith"
                (Just $ address "123 Fake St." "" "CA")
                [ phoneNumber HomePhone "555-555-5555"
                , phoneNumber CellPhone "555-555-0000"
                ]
      suite "Exercise 3a - Write 'sequence' in terms of 'traverse'" do
        test "TODO - 'empty' test which passes"
          $ Assert.equal true
          $ true
      suite "Exercise 3b - Write 'traverse' in terms of 'sequence'" do
        test "TODO - 'empty' test which passes"
          $ Assert.equal true
          $ true
-}
