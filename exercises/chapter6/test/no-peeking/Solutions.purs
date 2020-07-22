module Test.NoPeeking.Solutions where

import Prelude
import Data.Array (length, nubByEq)
import Data.Foldable (class Foldable, foldMap, foldl, foldr, maximum)
import Data.Hashable (class Hashable, hash, hashEqual)
import Data.Maybe (Maybe(..))
import Data.Monoid (power)

newtype Complex
  = Complex
  { real :: Number
  , imaginary :: Number
  }

instance showComplex :: Show Complex where
  show (Complex c) =
    let
      optional_plus
        | c.imaginary >= 0.0 = "+"
        | otherwise = ""
    in
      show c.real <> optional_plus <> show c.imaginary <> "i"

instance eqComplex :: Eq Complex where
  eq (Complex a) (Complex b) = a.real == b.real && a.imaginary == b.imaginary

data NonEmpty a
  = NonEmpty a (Array a)

instance eqNonEmpty :: Eq a => Eq (NonEmpty a) where
  eq (NonEmpty e1 a1) (NonEmpty e2 a2) = e1 == e2 && a1 == a2

instance semigroupNonEmpty :: Semigroup (NonEmpty a) where
  append (NonEmpty e1 a1) (NonEmpty e2 a2) = NonEmpty e1 (a1 <> [ e2 ] <> a2)

instance showNonEmpty :: Show a => Show (NonEmpty a) where
  show (NonEmpty e1 a1) = show e1 <> " " <> show a1

instance functorNonEmpty :: Functor NonEmpty where
  map func (NonEmpty e1 a1) = NonEmpty (func e1) (map func a1)

data Extended a
  = Finite a
  | Infinite

instance eqExtended :: Eq a => Eq (Extended a) where
  eq Infinite Infinite = true
  eq (Finite e1) (Finite e2) = e1 == e2
  eq _ _ = false

instance ordExtended :: Ord a => Ord (Extended a) where
  compare Infinite Infinite = EQ
  compare Infinite (Finite _) = GT
  compare (Finite _) Infinite = LT
  compare (Finite v1) (Finite v2) = compare v1 v2

instance foldableNonEmpty :: Foldable NonEmpty where
  foldr func st (NonEmpty val arr) = foldr func st ([ val ] <> arr)
  foldl func st (NonEmpty val arr) = foldl func st ([ val ] <> arr)
  foldMap func (NonEmpty val arr) = foldMap func ([ val ] <> arr)

data OneMore f a
  = OneMore a (f a)

instance foldableOneMore :: Foldable f => Foldable (OneMore f) where
  foldr func st (OneMore val more) = func val lastB
    where
    lastB = foldr func st more
  foldl func st (OneMore val more) = foldl func firstB more
    where
    firstB = (func st val)
  foldMap func (OneMore val more) = (func val) <> (foldMap func more)

unsafeMaximum :: Partial => Array Int -> Int
unsafeMaximum arr = case maximum arr of
  Just m -> m

class
  Monoid m <= Action m a where
  act :: m -> a -> a

newtype Multiply
  = Multiply Int

instance semigroupMultiply :: Semigroup Multiply where
  append (Multiply n) (Multiply m) = Multiply (n * m)

instance monoidMultiply :: Monoid Multiply where
  mempty = Multiply 1

instance actionMultiply :: Action Multiply Int where
  act (Multiply n) m = n * m

instance showMultiply :: Show Multiply where
  show (Multiply n) = "Multiply " <> show n

instance eqMultiply :: Eq Multiply where
  eq (Multiply n) (Multiply m) = n == m

instance repeatAction :: Action Multiply String where
  act (Multiply n) s = power s n

instance actionArray :: Action m a => Action m (Array a) where
  act m arr = map (act m) arr

newtype Self m
  = Self m

-- Why is Monoid constraint required here?
-- Seems like this is already specified by Action class
--instance actionSelf :: Action m (Self m) where
instance actionSelf :: Monoid m => Action m (Self m) where
  act m1 (Self m2) = Self (m1 <> m2)

instance eqSelf :: Eq m => Eq (Self m) where
  eq (Self m1) (Self m2) = m1 == m2

instance showSelf :: Show m => Show (Self m) where
  show (Self m) = "Self " <> show m

instance semigroupSelf :: Semigroup m => Semigroup (Self m) where
  append (Self a) (Self b) = Self (a <> b)

instance monoidSelf :: Monoid m => Monoid (Self m) where
  mempty = Self mempty

instance repeatActionMultSelf :: Action (Self Multiply) Int where
  act (Self (Multiply m)) s = m * s

arrayHasDuplicates :: forall a. Hashable a => Array a -> Boolean
arrayHasDuplicates arr =
  let
    hashAndValEqual a b = hashEqual a b && a == b
  in
    length arr /= (length $ nubByEq hashAndValEqual arr)

newtype Hour
  = Hour Int

instance eqHour :: Eq Hour where
  eq (Hour n) (Hour m) = mod n 12 == mod m 12

instance hashHour :: Hashable Hour where
  hash (Hour h) = hash $ mod h 12
