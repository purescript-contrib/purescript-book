module Data.AddressBook where

import Prelude

type Address
  = { street :: String
    , city :: String
    , state :: String
    }

-- ANCHOR: address_anno
address :: String -> String -> String -> Address
-- ANCHOR_END: address_anno
address street city state = { street, city, state }

-- ANCHOR: PhoneType
data PhoneType
  = HomePhone
  | WorkPhone
  | CellPhone
  | OtherPhone
-- ANCHOR_END: PhoneType

{-| derive has not been discussed yet but will be
covered in Ch 10.  Here it is needed by the unit
tests to define how to compare the PhoneType values
(HomePhone, WorkPhone, etc).
-}
derive instance eqPhoneType :: Eq PhoneType

instance showPhoneType :: Show PhoneType where
  show HomePhone = "HomePhone"
  show WorkPhone = "WorkPhone"
  show CellPhone = "CellPhone"
  show OtherPhone = "OtherPhone"

type PhoneNumber
  = { "type" :: PhoneType
    , number :: String
    }

-- ANCHOR: phoneNumber_anno
phoneNumber :: PhoneType -> String -> PhoneNumber
-- ANCHOR_END: phoneNumber_anno
phoneNumber ty number =
  { "type": ty
  , number: number
  }

type Person
  = { firstName :: String
    , lastName :: String
    , homeAddress :: Address
    , phones :: Array PhoneNumber
    }

-- ANCHOR: person_anno
person :: String -> String -> Address -> Array PhoneNumber -> Person
-- ANCHOR_END: person_anno
person firstName lastName homeAddress phones = { firstName, lastName, homeAddress, phones }

-- ANCHOR: examplePerson
examplePerson :: Person
examplePerson =
  person "John" "Smith"
    (address "123 Fake St." "FakeTown" "CA")
    [ phoneNumber HomePhone "555-555-5555"
    , phoneNumber CellPhone "555-555-0000"
    ]
-- ANCHOR_END: examplePerson
