module Main where

import Prelude
import Data.AddressBook (Address(..), Person(..), PhoneNumber(..), examplePerson)
import Data.AddressBook.Validation (Errors, validatePerson')
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Array ((..), length, modifyAt, zipWith)
import Effect (Effect)
import Data.Either (Either(..))
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.DOM as D
import React.Basic.DOM.Events (targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (ReactComponent, component, element, useReducer, (/\))
import React.Basic.Hooks as R
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

type State
  = { person :: Person
    , errors :: Errors
    }

initialState :: State
initialState =
  { person: examplePerson
  , errors: []
  }

data Action
  = UpdateFirstName (Maybe String)
  | UpdateLastName (Maybe String)
  | UpdateStreet (Maybe String)
  | UpdateCity (Maybe String)
  | UpdateState (Maybe String)
  | UpdatePhoneNumber Int (Maybe String)

reducer :: State -> Action -> State
reducer state@{ person: Person p@{ homeAddress: Address a } } action =
  let
    updatePhoneNumber s (PhoneNumber o) = PhoneNumber $ o { number = s }

    newPerson = case action of
      UpdateFirstName (Just value) -> Person p { firstName = value }
      UpdateLastName (Just value) -> Person p { lastName = value }
      UpdateStreet (Just value) -> Person p { homeAddress = Address a { street = value } }
      UpdateCity (Just value) -> Person p { homeAddress = Address a { city = value } }
      UpdateState (Just value) -> Person p { homeAddress = Address a { state = value } }
      UpdatePhoneNumber index (Just value) -> Person p { phones = fromMaybe p.phones $ modifyAt index (updatePhoneNumber value) p.phones }
      _ -> state.person
  in
    case validatePerson' newPerson of
      Left errors -> state { person = newPerson, errors = errors }
      Right _ -> state { person = newPerson, errors = [] }

formField :: String -> String -> String -> (Maybe String -> Action) -> (Action -> Effect Unit) -> R.JSX
formField name hint value actionConstructor dispatch =
  D.div
    { className: "form-group"
    , children:
        [ D.label
            { className: "col-sm-2 control-label"
            , children: [ D.text name ]
            }
        , D.div
            { className: "col-sm-3"
            , children:
                [ D.input
                    { className: "form-control"
                    , placeholder: hint
                    , value
                    , onChange: handler targetValue \v -> dispatch $ actionConstructor v
                    }
                ]
            }
        ]
    }

renderPhoneNumber :: (Action -> Effect Unit) -> PhoneNumber -> Int -> R.JSX
renderPhoneNumber dispatch (PhoneNumber phone) index =
  let
    actionConstructor :: Maybe String -> Action
    actionConstructor ms = UpdatePhoneNumber index ms
  in
    formField (show phone."type") "XXX-XXX-XXXX" phone.number actionConstructor dispatch

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
    { person: Person person@{ homeAddress: Address address }, errors } /\ dispatch <-
      useReducer initialState reducer
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
                          { className: "form-horizontal"
                          , children:
                              [ D.h3_ [ D.text "Basic Information" ]
                              , formField "First Name" "First Name" person.firstName UpdateFirstName dispatch
                              , formField "Last Name" "Last Name" person.lastName UpdateLastName dispatch
                              , D.h3_ [ D.text "Address" ]
                              , formField "Street" "Street" address.street UpdateStreet dispatch
                              , formField "City" "City" address.city UpdateCity dispatch
                              , formField "State" "State" address.state UpdateState dispatch
                              , D.h3_ [ D.text "Contact Information" ]
                              ]
                                <> zipWith (renderPhoneNumber dispatch) person.phones (0 .. length person.phones)
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
