module Main where

import Prelude
import Data.AddressBook (Address(..), Person(..), PhoneNumber(..), address, examplePerson, person)
import Data.AddressBook.Validation (Errors, validatePerson')
import Data.Array (mapWithIndex, updateAt)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console (log)
import Effect.Exception (throw)
import React.Basic.DOM as D
import React.Basic.DOM.Events (targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (ReactComponent, component, element, useState)
import React.Basic.Hooks as R
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

-- Note that there's a Purty formmating bug that
-- adds an unwanted blank line
-- https://gitlab.com/joneshf/purty/issues/77
renderValidationErrors :: Errors -> Array R.JSX
renderValidationErrors [] = []

renderValidationErrors xs =
  let
    rendererror :: String -> R.JSX
    rendererror err = D.li_ [ D.text err ]
  in
    [ D.div
        { className: "alert alert-danger row"
        , children: [ D.ul_ (map rendererror xs) ]
        }
    ]

-- Helper function to render a single form field with an
-- event handler to update
formField :: String -> String -> String -> ((String -> String) -> Effect Unit) -> R.JSX
formField name placeholder value setValue =
  D.label
    { className: "form-group row"
    , children:
        [ D.div
            { className: "col-sm col-form-label"
            , children: [ D.text name ]
            }
        , D.div
            { className: "col-sm"
            , children:
                [ D.input
                    { className: "form-control"
                    , placeholder
                    , value
                    , onChange:
                        let
                          handleValue :: Maybe String -> Effect Unit
                          handleValue (Just v) = setValue (\_ -> v)

                          handleValue Nothing = pure unit
                        in
                          handler targetValue handleValue
                    }
                ]
            }
        ]
    }

mkAddressBookApp2 :: Effect (ReactComponent {})
mkAddressBookApp2 =
  component
    "AddressBookApp"
    (\props -> pure $ D.text "Hi! I'm an address book")

mkAddressBookApp :: Effect (ReactComponent {})
mkAddressBookApp =
  -- incomming \props are unused
  component "AddressBookApp" \props -> R.do
    let
      -- Using "Named Pattern" with `@` so inner records
      -- of `Person` and `Address` can be more conveniently
      -- accessed as `p` and `a`.
      Person p@{ homeAddress: Address a } = examplePerson
    -- Each form field is tracked as a separate piece of state.
    -- `useState` takes a default initial value and returns the
    -- current value and a way to update the value.
    -- Consult react-hooks docs for a more detailed explanation of `useState`.
    Tuple firstName setFirstName <- useState p.firstName
    Tuple lastName setLastName <- useState p.lastName
    Tuple street setStreet <- useState a.street
    Tuple city setCity <- useState a.city
    Tuple state setState <- useState a.state
    Tuple phoneNumbers setPhoneNumbers <- useState p.phones
    let
      unvalidatedPerson =
        person firstName lastName
          (address street city state)
          phoneNumbers

      errors = case validatePerson' unvalidatedPerson of
        Left e -> e
        Right _ -> []

      -- helper-function to return array unchanged instead of Nothing if index is out of bounds
      updateAt' :: forall a. Int -> a -> Array a -> Array a
      updateAt' i x xs = fromMaybe xs (updateAt i x xs)

      renderPhoneNumber :: Int -> PhoneNumber -> R.JSX
      renderPhoneNumber index (PhoneNumber phone) =
        let
          -- Same signature as the other `set` hooks, but customized to update a specific phone index
          setPhoneNumber :: (String -> String) -> Effect Unit
          setPhoneNumber setter =
            setPhoneNumbers \_ ->
              updateAt'
                index
                -- Each `set` hook runs a provided `setter` function which describes
                -- how to determine the new state from the previous state.
                -- In our case, the formField handler ignores the previous state.
                (PhoneNumber phone { number = setter "ignore" })
                phoneNumbers
        in
          formField
            (show phone."type")
            "XXX-XXX-XXXX"
            phone.number
            setPhoneNumber
    pure
      $ D.div
          { className: "container"
          , children:
              renderValidationErrors errors
                <> [ D.div
                      { className: "row"
                      , children:
                          [ D.form_
                              $ [ D.h3_ [ D.text "Basic Information" ]
                                , formField "First Name" "First Name" firstName setFirstName
                                , formField "Last Name" "Last Name" lastName setLastName
                                , D.h3_ [ D.text "Address" ]
                                , formField "Street" "Street" street setStreet
                                , formField "City" "City" city setCity
                                , formField "State" "State" state setState
                                , D.h3_ [ D.text "Contact Information" ]
                                ]
                              <> mapWithIndex renderPhoneNumber phoneNumbers
                          ]
                      }
                  ]
          }

main :: Effect Unit
main = do
  log "Rendering address book component"
  -- Get window object
  w <- window
  -- Get window's HTML document
  doc <- document w
  -- Get "container" element in HTML
  ctr <- getElementById "container" $ toNonElementParentNode doc
  case ctr of
    Nothing -> throw "Container element not found."
    Just c -> do
      -- Create AddressBook react component
      addressBookApp <- mkAddressBookApp
      let
        -- Create JSX node from react component. Pass-in empty props
        app = element addressBookApp {}
      -- Render AddressBook JSX node in DOM "container" element
      D.render app c
