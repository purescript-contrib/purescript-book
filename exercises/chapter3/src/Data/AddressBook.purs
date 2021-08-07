-- ANCHOR: imports
module Data.AddressBook where

import Prelude

import Control.Plus (empty)
import Data.List (List(..), filter, head)
import Data.Maybe (Maybe)
-- ANCHOR_END: imports

-- ANCHOR: Address
type Address =
  { street :: String
  , city   :: String
  , state  :: String
  }
-- ANCHOR_END: Address

-- ANCHOR: Entry
type Entry =
  { firstName :: String
  , lastName  :: String
  , address   :: Address
  }
-- ANCHOR_END: Entry

-- ANCHOR: AddressBook
type AddressBook = List Entry
-- ANCHOR_END: AddressBook

-- ANCHOR: showAddress
showAddress :: Address -> String
showAddress addr = addr.street <> ", " <>
                   addr.city <> ", " <>
                   addr.state
-- ANCHOR_END: showAddress

-- ANCHOR: showEntry_signature
showEntry :: Entry -> String
-- ANCHOR_END: showEntry_signature
-- ANCHOR: showEntry_implementation
showEntry entry = entry.lastName <> ", " <>
                  entry.firstName <> ": " <>
                  showAddress entry.address
-- ANCHOR_END: showEntry_implementation

-- ANCHOR: emptyBook
emptyBook :: AddressBook
emptyBook = empty
-- ANCHOR_END: emptyBook

-- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions. NOTE TO MAINTAINER: If editing `insertEntry`, remember to also update the non-anchored (and unsimplified) version of this function that is hardcoded in the book text.
-- ANCHOR: insertEntry
-- ANCHOR: insertEntry_signature
insertEntry :: Entry -> AddressBook -> AddressBook
-- ANCHOR_END: insertEntry_signature
insertEntry = Cons
-- ANCHOR_END: insertEntry

-- This line should have been automatically deleted by resetSolutions.sh. See Chapter 2 for instructions. NOTE TO MAINTAINER: If editing `findEntry`, remember to also update the non-anchored (and unsimplified) version of this function that is hardcoded in the book text.
-- ANCHOR: findEntry_signature
findEntry :: String -> String -> AddressBook -> Maybe Entry
-- ANCHOR_END: findEntry_signature
-- ANCHOR: findEntry_implementation
findEntry firstName lastName = head <<< filter filterEntry
  where
-- ANCHOR_END: findEntry_implementation
  filterEntry :: Entry -> Boolean
  filterEntry entry = entry.firstName == firstName && entry.lastName == lastName

