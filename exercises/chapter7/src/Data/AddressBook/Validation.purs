module Data.AddressBook.Validation where

import Prelude
import Data.AddressBook (Address, Person, PhoneNumber, address, person, phoneNumber)
import Data.Either (Either(..))
import Data.String (length)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (V, unV, invalid)
import Partial.Unsafe (unsafePartial)

-----------------
-- Some simple early examples returning `Either` instead of `V`:

-- ANCHOR: nonEmpty1
nonEmpty1 :: String -> Either String Unit
nonEmpty1 "" = Left "Field cannot be empty"
nonEmpty1 _  = Right unit
-- ANCHOR_END: nonEmpty1

-- ANCHOR: validatePerson1
validatePerson1 :: Person -> Either String Person
validatePerson1 p =
  person <$> (nonEmpty1 p.firstName *> pure p.firstName)
         <*> (nonEmpty1 p.lastName  *> pure p.lastName)
         <*> pure p.homeAddress
         <*> pure p.phones
-- ANCHOR_END: validatePerson1

-- ANCHOR: validatePerson1Ado
validatePerson1Ado :: Person -> Either String Person
validatePerson1Ado p = ado
  f <- nonEmpty1 p.firstName *> pure p.firstName
  l <- nonEmpty1 p.lastName *> pure p.firstName
  in person f l p.homeAddress p.phones
-- ANCHOR_END: validatePerson1Ado

-----------------

-- ANCHOR: Errors
type Errors
  = Array String
-- ANCHOR_END: Errors

-- ANCHOR: nonEmpty
nonEmpty :: String -> String -> V Errors Unit
nonEmpty field "" = invalid [ "Field '" <> field <> "' cannot be empty" ]
nonEmpty _     _  = pure unit
-- ANCHOR_END: nonEmpty

-- ANCHOR: arrayNonEmpty
arrayNonEmpty :: forall a. String -> Array a -> V Errors Unit
arrayNonEmpty field [] =
  invalid [ "Field '" <> field <> "' must contain at least one value" ]
arrayNonEmpty _     _  =
  pure unit
-- ANCHOR_END: arrayNonEmpty

-- ANCHOR: lengthIs
lengthIs :: String -> Int -> String -> V Errors Unit
lengthIs field len value | length value /= len =
  invalid [ "Field '" <> field <> "' must have length " <> show len ]
lengthIs _     _   _     = pure unit
-- ANCHOR_END: lengthIs

-- ANCHOR: phoneNumberRegex
phoneNumberRegex :: Regex
phoneNumberRegex =
  unsafePartial case regex "^\\d{3}-\\d{3}-\\d{4}$" noFlags of
    Right r -> r
-- ANCHOR_END: phoneNumberRegex

-- ANCHOR: matches
matches :: String -> Regex -> String -> V Errors Unit
matches _     regex value | test regex value =
  pure unit
matches field _     _     =
  invalid [ "Field '" <> field <> "' did not match the required format" ]
-- ANCHOR_END: matches

-- ANCHOR: validateAddress
validateAddress :: Address -> V Errors Address
validateAddress a =
  address <$> (nonEmpty "Street"  a.street *> pure a.street)
          <*> (nonEmpty "City"    a.city   *> pure a.city)
          <*> (lengthIs "State" 2 a.state  *> pure a.state)
-- ANCHOR_END: validateAddress

-- ANCHOR: validateAddressAdo
validateAddressAdo :: Address -> V Errors Address
validateAddressAdo a = ado
  street <- (nonEmpty "Street"  a.street *> pure a.street)
  city   <- (nonEmpty "City"    a.city   *> pure a.city)
  state  <- (lengthIs "State" 2 a.state  *> pure a.state)
  in address street city state
-- ANCHOR_END: validateAddressAdo

-- ANCHOR: validatePhoneNumber
validatePhoneNumber :: PhoneNumber -> V Errors PhoneNumber
validatePhoneNumber pn =
  phoneNumber <$> pure pn."type"
              <*> (matches "Number" phoneNumberRegex pn.number *> pure pn.number)
-- ANCHOR_END: validatePhoneNumber

-- ANCHOR: validatePhoneNumberAdo
validatePhoneNumberAdo :: PhoneNumber -> V Errors PhoneNumber
validatePhoneNumberAdo pn = ado
  tpe    <- pure pn."type"
  number <- (matches "Number" phoneNumberRegex pn.number *> pure pn.number)
  in phoneNumber tpe number
-- ANCHOR_END: validatePhoneNumberAdo

-- ANCHOR: validatePerson
validatePerson :: Person -> V Errors Person
validatePerson p =
  person <$> (nonEmpty "First Name" p.firstName *> pure p.firstName)
         <*> (nonEmpty "Last Name" p.lastName   *> pure p.lastName)
         <*> validateAddress p.homeAddress
         <*> (arrayNonEmpty "Phone Numbers" p.phones *>
              traverse validatePhoneNumber p.phones)
-- ANCHOR_END: validatePerson

-- ANCHOR: validatePersonAdo
validatePersonAdo :: Person -> V Errors Person
validatePersonAdo p = ado
  firstName <- (nonEmpty "First Name" p.firstName *> pure p.firstName)
  lastName  <- (nonEmpty "Last Name" p.lastName   *> pure p.lastName)
  address   <- validateAddress p.homeAddress
  numbers   <- (arrayNonEmpty "Phone Numbers" p.phones *>
                traverse validatePhoneNumber p.phones)
  in person firstName lastName address numbers
-- ANCHOR_END: validatePersonAdo
