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

type Errors
  = Array String

nonEmpty :: String -> String -> V Errors Unit
nonEmpty field "" = invalid [ "Field '" <> field <> "' cannot be empty" ]

nonEmpty _ _ = pure unit

arrayNonEmpty :: forall a. String -> Array a -> V Errors Unit
arrayNonEmpty field [] = invalid [ "Field '" <> field <> "' must contain at least one value" ]

arrayNonEmpty _ _ = pure unit

lengthIs :: String -> Int -> String -> V Errors Unit
lengthIs field len value
  | length value /= len = invalid [ "Field '" <> field <> "' must have length " <> show len ]

lengthIs _ _ _ = pure unit

phoneNumberRegex :: Regex
phoneNumberRegex =
  unsafePartial case regex "^\\d{3}-\\d{3}-\\d{4}$" noFlags of
    Right r -> r

matches :: String -> Regex -> String -> V Errors Unit
matches _ regex value
  | test regex value = pure unit

matches field _ _ = invalid [ "Field '" <> field <> "' did not match the required format" ]

validateAddress :: Address -> V Errors Address
validateAddress a =
  address <$> (nonEmpty "Street" a.street *> pure a.street)
    <*> (nonEmpty "City" a.city *> pure a.city)
    <*> (lengthIs "State" 2 a.state *> pure a.state)

validatePhoneNumber :: PhoneNumber -> V Errors PhoneNumber
validatePhoneNumber pn =
  phoneNumber <$> pure pn."type"
    <*> (matches "Number" phoneNumberRegex pn.number *> pure pn.number)

validatePerson :: Person -> V Errors Person
validatePerson p =
  person <$> (nonEmpty "First Name" p.firstName *> pure p.firstName)
    <*> (nonEmpty "Last Name" p.lastName *> pure p.lastName)
    <*> validateAddress p.homeAddress
    <*> (arrayNonEmpty "Phone Numbers" p.phones *> traverse validatePhoneNumber p.phones)

validatePerson' :: Person -> Either Errors Person
validatePerson' p = unV Left Right $ validatePerson p
