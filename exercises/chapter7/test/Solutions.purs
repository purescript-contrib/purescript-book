module Test.Solutions where

import Prelude
import Data.AddressBook (Address, address)
import Data.AddressBook.Validation (Errors, matches, nonEmpty)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Validation.Semigroup as Semigroup
import Data.String.Regex (Regex(), regex)
import Data.String.Regex.Flags (noFlags)
import Partial.Unsafe (unsafePartial)

-- Just to prove continuous integration can be set up
example :: Boolean -> Boolean -> Boolean
example x y = x && y

{-| Exercise Group 1 -}
{-| Exercise 1 is in the regression tests -}
{-| Exercise 2 -}
lift3 ::
  forall a b c d f.
  Apply f =>
  (a -> b -> c -> d) ->
  f a ->
  f b ->
  f c ->
  f d
lift3 f x y z = f <$> x <*> y <*> z

combineMaybe :: ∀ a f. Applicative f => Maybe (f a) -> f (Maybe a)
combineMaybe (Just x) = map Just x

combineMaybe _ = pure Nothing

{-| Exercise Group 2 -}
validateAddressRegex :: Address -> Semigroup.V Errors Address
validateAddressRegex a =
  address <$> (nonEmpty "Street" a.street *> pure a.street)
    <*> (nonEmpty "City" a.city *> pure a.city)
    <*> (matches "State" stateAbbreviationRegex a.state *> pure a.state)

stateAbbreviationRegex :: Regex
stateAbbreviationRegex =
  unsafePartial case regex "^[A-Z]{2}$" noFlags of
    Right r -> r
