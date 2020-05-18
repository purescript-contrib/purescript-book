module Test.Solutions where

import Prelude
import Data.AddressBook
  ( Address
  , PhoneNumber
  -- , address
  )
-- import Data.AddressBook.Validation
--   ( Errors
--   , arrayNonEmpty
--   , matches
--   , nonEmpty
--   , validateAddress
--   , validatePhoneNumber
--   )
-- import Data.Either (Either(..))
import Data.Maybe
  ( Maybe
  )

-- import Data.Traversable (traverse)
-- import Data.Validation.Semigroup (V)
-- import Data.String.Regex (Regex(), regex)
-- import Data.String.Regex.Flags (noFlags)
-- import Effect (Effect)
-- import Effect.Console (logShow)
-- import Partial.Unsafe (unsafePartial)
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

{-| Exercise 3 - implement combineMaybe -}
-- combineMaybe :: ∀ a f. Applicative f => Maybe (f a) -> f (Maybe a)
{-| Exercise Group 2 
-}
{-| Exercise 1 - implement validateAddressRegex
Hint: also implement stateAbbreviationRegex and have validateAddressRegex use it.
-}
-- validateAddressRegex :: Address -> V Errors Address
-- stateAbbreviationRegex :: Regex
{-| Exercise 2 - check for strings only containing whitespace
Hint: also implement notOnlyWhitespaceRegex and have validateAddressRegex' use it.
-}
-- validateAddressRegex' :: Address -> V Errors Address
-- notOnlyWhitespaceRegex :: Regex
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

{-| Implement a instance of a Tree -}
-- sampleTree :: Tree Int
{-| Implement an in-order traversal -}
-- traverseInOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
{-| Implement a pre-order traversal -}
-- traversePreOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
{-| Implement a reverse order -}
-- traversePostOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
{-| Here's the code to run the 3 cases
runTraversableExercise :: Effect Unit
runTraversableExercise = do
  t1 <- traverseInOrder logShow sampleTree -- 1 2 3
  t2 <- traversePreOrder logShow sampleTree -- 2 1 3
  t3 <- traversePostOrder logShow sampleTree -- 1 3 2  
  pure unit
-}
{-| Exercise 2: Test when 'address' field is a Maybe
Person' shows the Maybe placement; person' is a convenient Person' constructor.
-}
type Person'
  = { firstName :: String
    , lastName :: String
    , homeAddress :: Maybe Address
    , phones :: Array PhoneNumber
    }

person' :: String -> String -> Maybe Address -> Array PhoneNumber -> Person'
person' firstName lastName homeAddress phones = { firstName, lastName, homeAddress, phones }

{-| Implement the validation for the new Maybe requirement -}
-- validatePersonWithMaybeAddress :: Person' -> V Errors Person'
{-| Exercise 3: Try to write sequence in terms of traverse and vice-versa

TODO

-}
