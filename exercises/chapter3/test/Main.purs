module Test.Main where

import Prelude
import Data.AddressBook (emptyBook, findEntry, insertEntry)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Test.Solutions (findEntryByStreet, isInBook, removeDuplicates)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main =
  runTest do
    suite "Exercise Group 0" do
      let
        john =
          { firstName: "John"
          , lastName: "Smith"
          , address:
              { street: "123 Fake St.", city: "Faketown", state: "CA" }
          }

        peggy =
          { firstName: "Peggy"
          , lastName: "Hill"
          , address:
              { street: "84 Rainey St.", city: "Arlen", state: "TX" }
          }

        ned =
          { firstName: "Ned"
          , lastName: "Flanders"
          , address:
              { street: "740 Evergreen Terrace", city: "Springfield", state: "USA" }
          }

        book =
          insertEntry john
            $ insertEntry peggy
            $ insertEntry ned
                emptyBook

        bookWithDuplicate = insertEntry john book
      -- Exercise 0 is already completed
      suite "Exercise 0 - Name lookup" do
        test "Lookup existing"
          $ Assert.equal (Just ned)
          $ findEntry ned.firstName ned.lastName book
        test "Lookup missing"
          $ Assert.equal Nothing
          $ findEntry "unknown" "person" book
      suite "Exercise 2 - Street lookup" do
        test "Lookup existing"
          $ Assert.equal (Just john)
          $ findEntryByStreet john.address.street book
        test "Lookup missing"
          $ Assert.equal Nothing
          $ findEntryByStreet "456 Nothing St." book
      suite "Exercise 3 - Name check" do
        test "Check existing"
          $ Assert.equal true
          $ isInBook ned.firstName ned.lastName book
        test "Check missing"
          $ Assert.equal false
          $ isInBook "unknown" "person" book
      test "Exercise 4 - Remove duplicates" do
        Assert.equal book
          $ removeDuplicates john.firstName john.lastName bookWithDuplicate
