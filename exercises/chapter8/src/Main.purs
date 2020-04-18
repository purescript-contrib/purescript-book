module Main where

import Prelude
import Data.AddressBook (PhoneNumber(..), PhoneType(..), address, person, phoneNumber)
import Data.AddressBook.Validation (Errors, validatePerson')
import Data.Array (modifyAt, mapWithIndex)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.DOM as D
import React.Basic.DOM.Events (targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (ReactComponent, component, element, useState, (/\))
import React.Basic.Hooks as R
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

formField :: String -> String -> String -> ((String -> String) -> Effect Unit) -> R.JSX
formField name placeholder value setValue =
  D.label
    { className: "form-group row"
    , children:
        [ D.div
            { className: "col-sm col-form-label", children: [ D.text name ]
            }
        , D.div
            { className: "col-sm"
            , children:
                [ D.input
                    { className: "form-control"
                    , placeholder
                    , value
                    , onChange:
                        handler targetValue \v ->
                          setValue \_ -> fromMaybe "" v
                    }
                ]
            }
        ]
    }

renderValidationError :: String -> R.JSX
renderValidationError err = D.li_ [ D.text err ]

renderValidationErrors :: Errors -> Array R.JSX
renderValidationErrors [] = []

renderValidationErrors xs =
  [ D.div
      { className: "alert alert-danger"
      , children: [ D.ul_ (map renderValidationError xs) ]
      }
  ]

mkAddressBookApp :: Effect (ReactComponent {})
mkAddressBookApp = do
  component "AddressBookApp" \props -> R.do
    firstName /\ setFirstName <- useState "John"
    lastName /\ setLastName <- useState "Smith"
    street /\ setStreet <- useState "123 Fake St."
    city /\ setCity <- useState "FakeTown"
    state /\ setState <- useState "CA"
    phoneNumbers /\ setPhoneNumbers <-
      useState
        [ phoneNumber HomePhone "555-555-5555"
        , phoneNumber CellPhone "555-555-0000"
        ]
    let
      unvalidatedPerson =
        person firstName lastName
          (address street city state)
          phoneNumbers

      errors = case validatePerson' unvalidatedPerson of
        Left e -> e
        Right _ -> []

      modifyAt' i f as = fromMaybe as (modifyAt i f as)

      renderPhoneNumber :: Int -> PhoneNumber -> R.JSX
      renderPhoneNumber index (PhoneNumber phone) =
        formField
          (show phone."type")
          "XXX-XXX-XXXX"
          phone.number
          ( \setPhoneNumber ->
              setPhoneNumbers \_ ->
                modifyAt'
                  index
                  (\(PhoneNumber n) -> PhoneNumber (n { number = setPhoneNumber n.number }))
                  phoneNumbers
          )
    pure
      $ D.div
          { className: "container"
          , children:
              [ D.div
                  { className: "row"
                  , children: renderValidationErrors errors
                  }
              , D.div
                  { className: "row"
                  , children:
                      [ D.form
                          { children:
                              [ D.h3_ [ D.text "Basic Information" ]
                              , formField "First Name" "First Name" firstName setFirstName
                              , formField "Last Name" "Last Name" lastName setLastName
                              , D.h3_ [ D.text "Address" ]
                              , formField "Street" "Street" street setStreet
                              , formField "City" "City" city setCity
                              , formField "State" "State" state setState
                              , D.h3_ [ D.text "Contact Information" ]
                              ]
                                <> mapWithIndex renderPhoneNumber phoneNumbers
                          }
                      ]
                  }
              ]
          }

main :: Effect Unit
main = do
  container <- getElementById "container" =<< (map toNonElementParentNode $ document =<< window)
  case container of
    Nothing -> throw "Container element not found."
    Just c -> do
      addressBookApp <- mkAddressBookApp
      let
        app = element addressBookApp {}
      render app c
