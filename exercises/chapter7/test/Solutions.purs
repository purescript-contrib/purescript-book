module Test.Solutions where

import Prelude
import Data.AddressBook (Address, address)
import Data.AddressBook.Validation (Errors, matches, nonEmpty)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Validation.Semigroup as Semigroup
import Data.String.Regex (Regex(), regex)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Console (logShow)
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
{-| Exercise 1: Write a Traversable instance for a binary tree data structure.

Acknowledgeent: this solution presented by hrk at
https://discourse.purescript.org/t/purescript-by-example-tree-traversal-question/981/2
Run as follows:

spago repl
> import Test.Solutions
> runTraversableExercise
1
2
3
2
1
3
1
3
2
unit

> 

The numbers above illustrate different traversal orders.

TODO: Incorporate this in unit tests.
-}
data Tree a
  = Leaf
  | Branch (Tree a) a (Tree a)

sampleTree :: Tree Int
sampleTree = Branch (Branch Leaf 1 Leaf) 2 (Branch Leaf 3 Leaf)

traverseInOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
traverseInOrder _ Leaf = pure Leaf

-- first evaluate left branch, then node, then right branch
traverseInOrder f (Branch l x r) = Branch <$> traverseInOrder f l <*> f x <*> traverseInOrder f r

traversePreOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
traversePreOrder _ Leaf = pure Leaf

-- first evaluate node, then left branch and then right branch. Notice the lambda function shuffles the arguments where they need to be
traversePreOrder f (Branch l x r) = (\x' l' r' -> Branch l' x' r') <$> f x <*> traversePreOrder f l <*> traversePreOrder f r

traversePostOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
traversePostOrder _ Leaf = pure Leaf

traversePostOrder f (Branch l x r) = (\l' r' x' -> Branch l' x' r') <$> traversePostOrder f l <*> traversePostOrder f r <*> f x

runTraversableExercise :: Effect Unit
runTraversableExercise = do
  t1 <- traverseInOrder logShow sampleTree -- 1 2 3
  t2 <- traversePreOrder logShow sampleTree -- 2 1 3
  t3 <- traversePostOrder logShow sampleTree -- 1 3 2  
  pure unit

{-| Exercise 2: Modify the code to make the address field of the Person type optional

TODO

-}
{- Exercise 3: Try to write sequence in terms of traverse and vice-versa

TODO

-}
