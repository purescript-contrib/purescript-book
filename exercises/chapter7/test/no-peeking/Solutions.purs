module Test.NoPeeking.Solutions where

import Prelude

import Control.Apply (lift2)
import Data.AddressBook (Address, PhoneNumber, address)
import Data.AddressBook.Validation (Errors, matches, nonEmpty, validateAddress, validatePhoneNumbers)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Maybe (Maybe(..))
import Data.String.Regex (Regex)
import Data.String.Regex.Flags (noFlags)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Traversable (class Foldable, class Traversable, foldMap, foldl, foldr, sequence, traverse)
import Data.Validation.Semigroup (V)

{-| Exercise Group 1 -}
-- Exercise 1
addMaybe :: forall a. Semiring a => Maybe a -> Maybe a -> Maybe a
addMaybe = lift2 add

subMaybe :: forall a. Ring a => Maybe a -> Maybe a -> Maybe a
subMaybe = lift2 sub

mulMaybe :: forall a. Semiring a => Maybe a -> Maybe a -> Maybe a
mulMaybe = lift2 mul

divMaybe :: forall a. EuclideanRing a => Maybe a -> Maybe a -> Maybe a
divMaybe = lift2 div

-- Exercise 2
addApply :: forall f a. Apply f => Semiring a => f a -> f a -> f a
addApply = lift2 add

mulApply :: forall f a. Apply f => Semiring a => f a -> f a -> f a
mulApply = lift2 mul

subApply :: forall f a. Apply f => Ring a => f a -> f a -> f a
subApply = lift2 sub

divApply :: forall f a. Apply f => EuclideanRing a => f a -> f a -> f a
divApply = lift2 div

-- Exercise 3
combineMaybe :: forall a f. Applicative f => Maybe (f a) -> f (Maybe a)
combineMaybe (Just x) = map Just x

combineMaybe _ = pure Nothing

{-| Exercise Group 2 -}
-- Exercise 1
stateRegex :: Regex
stateRegex = unsafeRegex "^[a-zA-Z]{2}$" noFlags

-- Exercise 2
nonEmptyRegex :: Regex
nonEmptyRegex = unsafeRegex "\\S" noFlags

-- Exercise 3
validateAddressImproved :: Address -> V Errors Address
validateAddressImproved a =
  address
    <$> matches "Street" nonEmptyRegex a.street
    <*> matches "City"   nonEmptyRegex a.city
    <*> matches "State"  stateRegex    a.state

{-| Exercise Group 3 -}
-- Exercise 1
data Tree a
  = Leaf
  | Branch (Tree a) a (Tree a)

-- Solution using derived instances:

derive instance eqTree :: Eq a => Eq (Tree a)

derive instance genericTree :: Generic (Tree a) _

instance showTree :: Show a => Show (Tree a) where
  show t = genericShow t

{-
-- Solution using manually-written instances:

instance eqTree :: Eq a => Eq (Tree a) where
  eq Leaf Leaf = true
  eq (Branch t1a va t2a) (Branch t1b vb t2b)
      =  t1a == t1b
      && va  == vb
      && t2a == t2b
  eq _ _ = false

instance showTree :: Show a => Show (Tree a) where
  show Leaf = "Leaf"
  show (Branch t1 v t2) =
    "(Branch " <> show t1 <> " " <> show v <> " " <> show t2 <> ")"
-}

-- Exercise 2
instance functorTree :: Functor Tree where
  map _ Leaf = Leaf
  map f (Branch t1 v t2) = Branch (map f t1) (f v) (map f t2)

instance foldableTree :: Foldable Tree where
  foldl _ acc Leaf = acc
  foldl f acc (Branch t1 v t2) = foldl f (f (foldl f acc t1) v) t2
  foldr _ acc Leaf = acc
  foldr f acc (Branch t1 v t2) = foldr f (f v (foldr f acc t2)) t1
  foldMap _ Leaf = mempty
  foldMap f (Branch t1 v t2) = foldMap f t1 <> f v <> foldMap f t2

instance traversableTree :: Traversable Tree where
  traverse _ Leaf = pure Leaf
  traverse f (Branch t1 v t2) = ado
    mt1 <- traverse f t1
    mv <- f v
    mt2 <- traverse f t2
    in Branch mt1 mv mt2
  -- Equivalent
  --traverse f (Branch t1 v t2) = Branch <$> traverse f t1 <*> f v <*> traverse f t2
  sequence Leaf = pure Leaf
  sequence (Branch t1 v t2) = ado
    mt1 <- sequence t1
    mv <- v
    mt2 <- sequence t2
    in Branch mt1 mv mt2

-- Exercise 3
traversePreOrder :: forall a m b. Applicative m => (a -> m b) -> Tree a -> m (Tree b)
traversePreOrder _ Leaf = pure Leaf

traversePreOrder f (Branch t1 v t2) = ado
  mv <- f v
  mt1 <- traversePreOrder f t1
  mt2 <- traversePreOrder f t2
  in Branch mt1 mv mt2

-- Exercise 4
traversePostOrder :: forall a m b. Applicative m => (a -> m b) -> Tree a -> m (Tree b)
traversePostOrder _ Leaf = pure Leaf

traversePostOrder f (Branch t1 v t2) = ado
  mt1 <- traversePostOrder f t1
  mt2 <- traversePostOrder f t2
  mv <- f v
  in Branch mt1 mv mt2

-- Exercise 5
type PersonOptionalAddress
  = { firstName :: String
    , lastName :: String
    , homeAddress :: Maybe Address
    , phones :: Array PhoneNumber
    }

personOptionalAddress :: String -> String -> Maybe Address -> Array PhoneNumber -> PersonOptionalAddress
personOptionalAddress firstName lastName homeAddress phones = { firstName, lastName, homeAddress, phones }

validatePersonOptionalAddress :: PersonOptionalAddress -> V Errors PersonOptionalAddress
validatePersonOptionalAddress p =
  personOptionalAddress
    <$> nonEmpty "First Name" p.firstName
    <*> nonEmpty "Last Name" p.lastName
    <*> traverse validateAddress p.homeAddress
    <*> validatePhoneNumbers "Phone Numbers" p.phones

-- Exercise 6
sequenceUsingTraverse :: forall a m t. Traversable t => Applicative m => t (m a) -> m (t a)
sequenceUsingTraverse t = traverse identity t

-- Exercise 7
traverseUsingSequence :: forall a b m t. Traversable t => Applicative m => (a -> m b) -> t a -> m (t b)
traverseUsingSequence f t = sequence $ map f t
