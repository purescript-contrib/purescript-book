module Test.MySolutions where

import Prelude

import Data.AddressBook (Entry, AddressBook)
import Data.List (filter, head, nubByEq, null)
import Data.Maybe (Maybe)

findEntryByStreet :: String -> AddressBook -> Maybe Entry
findEntryByStreet x = head <<< filter filterEntry
  where
    filterEntry :: Entry -> Boolean
    filterEntry = (==) x <<< _.address.street

isInBook :: String -> String -> AddressBook -> Boolean
isInBook fn ln = not null <<< filter (\a -> a.firstName == fn && a.lastName == ln)

removeDuplicates :: AddressBook -> AddressBook
removeDuplicates = nubByEq (\a b -> a.firstName == b.firstName && a.lastName == b.lastName)
