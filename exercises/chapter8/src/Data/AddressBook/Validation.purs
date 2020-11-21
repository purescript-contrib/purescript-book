module Data.AddressBook.Validation where

import Prelude

import Data.AddressBook (Address, Person, PhoneNumber, address, person, phoneNumber)
import Data.Either (Either(..))
import Data.String (length)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (V, invalid, toEither)

type Errors
  = Array String

nonEmpty :: String -> String -> V Errors String
nonEmpty field ""     = invalid [ "Field '" <> field <> "' cannot be empty" ]
nonEmpty _     value  = pure value

validatePhoneNumbers :: String -> Array PhoneNumber -> V Errors (Array PhoneNumber)
validatePhoneNumbers field []      =
  invalid [ "Field '" <> field <> "' must contain at least one value" ]
validatePhoneNumbers _     phones  =
  traverse validatePhoneNumber phones

lengthIs :: String -> Int -> String -> V Errors String
lengthIs field len value | length value /= len =
  invalid [ "Field '" <> field <> "' must have length " <> show len ]
lengthIs _     _   value = pure value

phoneNumberRegex :: Either String Regex
phoneNumberRegex = regex "^\\d{3}-\\d{3}-\\d{4}$" noFlags

matches :: String -> Either String Regex -> String -> V Errors String
matches _    (Right regex) value | test regex value 
                                 = pure value
matches _    (Left  error) _     = invalid [ error ]
matches field _            _     = invalid [ "Field '" <> field <> "' did not match the required format" ]

validateAddress :: Address -> V Errors Address
validateAddress a =
  address <$> nonEmpty "Street"  a.street
          <*> nonEmpty "City"    a.city
          <*> lengthIs "State" 2 a.state

validatePhoneNumber :: PhoneNumber -> V Errors PhoneNumber
validatePhoneNumber pn =
  phoneNumber <$> pure pn."type"
              <*> matches "Number" phoneNumberRegex pn.number

validatePerson :: Person -> V Errors Person
validatePerson p =
  person <$> nonEmpty "First Name" p.firstName
         <*> nonEmpty "Last Name" p.lastName
         <*> validateAddress p.homeAddress
         <*> validatePhoneNumbers "Phone Numbers" p.phones

validatePerson' :: Person -> Either Errors Person
validatePerson' p = toEither $ validatePerson p
