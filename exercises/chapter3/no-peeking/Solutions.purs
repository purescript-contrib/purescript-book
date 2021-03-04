module Test.NoPeeking.Solutions where

import Prelude
import Data.AddressBook (AddressBook, Entry)
import Data.List (filter, head, nubByEq, null)
import Data.Maybe (Maybe)

findEntryByStreet :: String -> AddressBook -> Maybe Entry
-- Equivalent: findEntryByStreet streetName book = head (filter filterEntry book)
-- Equivalent: findEntryByStreet streetName book = head $ filter filterEntry book
findEntryByStreet streetName = head <<< filter filterEntry
  where
  filterEntry :: Entry -> Boolean
  filterEntry e = e.address.street == streetName

-- Example alternative implementation using property accessor
findEntryByStreet' :: String -> AddressBook -> Maybe Entry
findEntryByStreet' streetName = head <<< filter (_.address.street >>> eq streetName)

isInBook :: String -> String -> AddressBook -> Boolean
-- Equivalent: isInBook firstName lastName book = not null $ filter filterEntry book
isInBook firstName lastName = not null <<< filter filterEntry
  where
  filterEntry :: Entry -> Boolean
  filterEntry entry =
     entry.firstName == firstName &&
     entry.lastName  == lastName

removeDuplicates :: AddressBook -> AddressBook
-- Equivalent: removeDuplicates book = nubByEq entriesAreDuplicated book
removeDuplicates = nubByEq entriesAreDuplicated
  where
  entriesAreDuplicated :: Entry -> Entry -> Boolean
  entriesAreDuplicated e1 e2 =
    e1.firstName == e2.firstName &&
    e1.lastName  == e2.lastName
