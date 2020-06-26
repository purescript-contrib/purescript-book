module Test.NoPeeking.Solutions where

import Prelude
import Data.AddressBook (AddressBook, Entry)
import Data.List (filter, head, nubBy, null)
import Data.Maybe (Maybe)

findEntryByStreet :: String -> AddressBook -> Maybe Entry
-- Equivalent: findEntryByStreet streetName book = head $ filter filterEntry book
findEntryByStreet streetName = filter filterEntry >>> head
  where
  filterEntry :: Entry -> Boolean
  filterEntry e = e.address.street == streetName

isInBook :: String -> String -> AddressBook -> Boolean
isInBook firstName lastName book = not null $ filter filterEntry book
  where
  filterEntry :: Entry -> Boolean
  filterEntry entry = entry.firstName == firstName && entry.lastName == lastName

removeDuplicates :: AddressBook -> AddressBook
removeDuplicates book = nubBy filterEntry book
  where
  filterEntry :: Entry -> Entry -> Boolean
  filterEntry e1 e2 = e1.firstName == e2.firstName && e1.lastName == e2.lastName
