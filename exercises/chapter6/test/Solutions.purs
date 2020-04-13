module Test.Solutions where

import Prelude

newtype Complex
  = Complex
  { real :: Number
  , imaginary :: Number
  }

data NonEmpty a
  = NonEmpty a (Array a)

data Extended a
  = Finite a
  | Infinite

data OneMore f a
  = OneMore a (f a)

-- instance foldableOneMore :: Foldable f => Foldable (OneMore f) where
-- todo
-- unsafeMaximum :: Partial => Array Int -> Int
-- todo
class
  Monoid m <= Action m a where
  act :: m -> a -> a

newtype Multiply
  = Multiply Int

instance semigroupMultiply :: Semigroup Multiply where
  append (Multiply n) (Multiply m) = Multiply (n * m)

instance monoidMultiply :: Monoid Multiply where
  mempty = Multiply 1

-- instance repeatAction :: Action Multiply String where
-- todo
-- instance actionArray :: Action m a => Action m (Array a) where
-- todo
newtype Self m
  = Self m

newtype Hour
  = Hour Int

instance eqHour :: Eq Hour where
  eq (Hour n) (Hour m) = mod n 12 == mod m 12
