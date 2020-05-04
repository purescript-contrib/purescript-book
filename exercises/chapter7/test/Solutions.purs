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

validateAddressRegex' :: Address -> Semigroup.V Errors Address
validateAddressRegex' a =
  address <$> (nonEmpty "Street" a.street *> pure a.street)
    <*> (matches "City" notOnlyWhitespaceRegex a.city *> pure a.city)
    <*> (matches "State" stateAbbreviationRegex a.state *> pure a.state)

notOnlyWhitespaceRegex :: Regex
notOnlyWhitespaceRegex =
  unsafePartial case regex "[0-9A-Za-z]" noFlags of
    Right r -> r

{-| Exercise Group 3 -}
{-| Exercise 1: Write a Traversable instance for a binary tree data structure -}
data Tree a
  = Leaf
  | Branch (Tree a) a (Tree a)

sampleTree :: Tree Int
sampleTree = Branch (Branch Leaf 1 Leaf) 2 (Branch Leaf 3 Leaf)

-- sequence :: ∀ a f t. Applicative f => Traversable t => t (f a) -> f (t a)
traverseInOrder :: ∀ f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
traverseInOrder _ Leaf = pure Leaf

traverseInOrder f (Branch l c r) = Branch <$> traverseInOrder f l <*> f c <*> traverseInOrder f r
