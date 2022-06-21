module Test.MySolutions  where

import Prelude
import Data.AddressBook (AddressBook,Entry)
import Data.List (filter,head,null,nubByEq)
import Data.Maybe (Maybe)
-- Note to reader: Add your solutions to this file

findEntryByStreet :: String -> AddressBook -> Maybe Entry
findEntryByStreet street addressBook = head (filter filterEntry addressBook)
  where
    filterEntry :: Entry -> Boolean
    filterEntry entry = entry.address.street == street

findEntryByStreet2 :: String -> AddressBook -> Maybe Entry
findEntryByStreet2 street = 
  filter (_.address.street >>> eq street) 
  >>> head

isInBook :: String -> String -> AddressBook -> Boolean
isInBook firstName lastName = 
  filter filterFirstName 
  >>> filter filterLastName 
  >>> null 
  >>> not
  where 
    filterFirstName :: Entry -> Boolean
    filterFirstName = _.firstName >>> eq firstName

    filterLastName :: Entry -> Boolean
    filterLastName = _.lastName >>> eq lastName

removeDuplicates :: AddressBook -> AddressBook
removeDuplicates = 
  nubByEq filterByName
  where
    filterByName :: Entry -> Entry -> Boolean
    filterByName entry1 entry2 = entry1.firstName == entry2.firstName && entry1.lastName == entry2.lastName