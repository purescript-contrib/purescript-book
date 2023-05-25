module Test.NoPeeking.Solutions where

import Prelude

import Data.Array (length, nub, nubByEq, nubEq)
import Data.Foldable (class Foldable, foldMap, foldl, foldr, maximum)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Hashable (class Hashable, hash, hashEqual)
import Data.Maybe (Maybe(..))
import Data.Monoid (power)
import Data.Newtype (class Newtype, over2, wrap)

-- ANCHOR: Point
newtype Point
      = Point
      { x :: Number
      , y :: Number
      }
-- ANCHOR_END: Point

instance Show Point where
  show (Point p) =
    "(" <> show p.x <> ", " <> show p.y <> ")"

-- ANCHOR: Complex
newtype Complex
  = Complex
  { real :: Number
  , imaginary :: Number
  }
-- ANCHOR_END: Complex

instance Show Complex where
  show (Complex c) =
    let
      optional_plus
        | c.imaginary >= 0.0 = "+"
        | otherwise = ""
    in
      show c.real <> optional_plus <> show c.imaginary <> "i"

derive instance Eq Complex
{-
-- Manual solution
instance Eq Complex where
  eq (Complex a) (Complex b) = a == b
  -- or
  -- eq (Complex a) (Complex b) = a.real == b.real && a.imaginary == b.imaginary
-}

derive instance Newtype Complex _

instance Semiring Complex where
  add = over2 Complex add
  mul = over2 Complex
          \ { real: r1, imaginary: i1 }
            { real: r2, imaginary: i2 }
          ->
            { real:      r1 * r2 - i1 * i2
            , imaginary: r1 * i2 + r2 * i1
            }
  zero = wrap zero
  one = wrap { real: one, imaginary: zero }
{-
-- Without Newtype
instance Semiring Complex where
  add (Complex c1) (Complex c2) = Complex $ c1 + c2
  mul
    (Complex { real: r1, imaginary: i1 })
    (Complex { real: r2, imaginary: i2 })
      = Complex
          { real:      r1 * r2 - i1 * i2
          , imaginary: r1 * i2 + r2 * i1
          }
  zero = Complex zero
  one = Complex { real: one, imaginary: zero }
  -- Could instead write `zero` and `one` more explicitly
  --zero = Complex {real: 0.0, imaginary: 0.0}
  --one = Complex {real: 1.0, imaginary: 0.0}
-}

derive newtype instance Ring Complex
{-
-- Manual solution
instance Ring Complex where
  sub (Complex a) (Complex b) = Complex $ a - b
-}

-- ANCHOR: Shape
data Shape
      = Circle Point Number
      | Rectangle Point Number Number
      | Line Point Point
      | Text Point String
-- ANCHOR_END: Shape

derive instance Generic Shape _

instance Show Shape where
  show = genericShow
{-
-- Manual solution
instance Show Shape where
  show (Circle p r) = "(Circle " <> show p <> " " <> show r <> ")"
  show (Rectangle p l w) = "(Rectangle " <> show p <> " " <> show l <> " " <> show w <> ")"
  show (Line p1 p2) = "(Line " <> show p1 <> " " <> show p2 <> ")"
  show (Text p s) = "(Text " <> show p <> " " <> show s <> ")"
-}

-- ANCHOR: NonEmpty
data NonEmpty a = NonEmpty a (Array a)
-- ANCHOR_END: NonEmpty

instance Eq a => Eq (NonEmpty a) where
  eq (NonEmpty e1 a1) (NonEmpty e2 a2) = e1 == e2 && a1 == a2
{-
-- Derived solution
derive instance Eq a => Eq (NonEmpty a)
-}

instance Semigroup (NonEmpty a) where
  append (NonEmpty e1 a1) (NonEmpty e2 a2) = NonEmpty e1 (a1 <> [ e2 ] <> a2)

instance Show a => Show (NonEmpty a) where
  show (NonEmpty e1 a1) = show e1 <> " " <> show a1

derive instance Functor NonEmpty
{-
-- Manual solution
instance Functor NonEmpty where
  map func (NonEmpty e1 a1) = NonEmpty (func e1) (map func a1)
-}

-- ANCHOR: Extended
data Extended a = Infinite | Finite a 
-- ANCHOR_END: Extended

derive instance Eq a => Eq (Extended a)
{-
-- Manual Eq
instance Eq a => Eq (Extended a) where
  eq Infinite Infinite = true
  eq (Finite e1) (Finite e2) = e1 == e2
  eq _ _ = false
-}

instance Ord a => Ord (Extended a) where
  compare Infinite Infinite = EQ
  compare Infinite (Finite _) = GT
  compare (Finite _) Infinite = LT
  compare (Finite v1) (Finite v2) = compare v1 v2
{-
-- Note that it would have been possible to derive Ord if
-- the constructor order was reversed, although using implicit
-- ordering may make our intentions less clear if we care about
-- how things are ordered.
derive instance Ord a => Ord (Extended a)
-}

instance Foldable NonEmpty where
  foldr func st (NonEmpty val arr) = foldr func st ([ val ] <> arr)
  foldl func st (NonEmpty val arr) = foldl func st ([ val ] <> arr)
  foldMap func (NonEmpty val arr) = foldMap func ([ val ] <> arr)

-- ANCHOR: OneMore
data OneMore f a = OneMore a (f a)
-- ANCHOR_END: OneMore

-- ANCHOR: OneMore_Foldable
instance Foldable f => Foldable (OneMore f) where
-- ANCHOR_END: OneMore_Foldable
  foldr func st (OneMore val more) = func val lastB
    where
    lastB = foldr func st more
  foldl func st (OneMore val more) = foldl func firstB more
    where
    firstB = (func st val)
  foldMap func (OneMore val more) = (func val) <> (foldMap func more)

derive instance Eq Point
derive instance Eq Shape

dedupShapes :: Array Shape -> Array Shape
dedupShapes = nubEq

derive instance Ord Point
derive instance Ord Shape

dedupShapesFast :: Array Shape -> Array Shape
dedupShapesFast = nub

unsafeMaximum :: Partial => Array Int -> Int
unsafeMaximum arr = case maximum arr of
  Just m -> m

-- ANCHOR: Action
class Monoid m <= Action m a where
      act :: m -> a -> a
-- ANCHOR_END: Action

-- ANCHOR: Multiply
newtype Multiply = Multiply Int
-- ANCHOR_END: Multiply

-- ANCHOR: semigroupMultiply
instance Semigroup Multiply where
      append (Multiply n) (Multiply m) = Multiply (n * m)
-- ANCHOR_END: semigroupMultiply

-- ANCHOR: monoidMultiply
instance Monoid Multiply where
      mempty = Multiply 1
-- ANCHOR_END: monoidMultiply

-- ANCHOR: Multiply_Action
instance Action Multiply Int where
-- ANCHOR_END: Multiply_Action
  act (Multiply n) m = n * m

{-
-- Alternative solution #1
instance Action Multiply Int where
  act (Multiply n) m = m / n
-}

{-
-- Alternative solution #2
-- The module `Data.Int` is from the package `integers`.
-- You can run `spago install integers` to use it.
import Data.Int (pow)

instance Action Multiply Int where
  act (Multiply n) m = pow m n
-}

{-
-- Alternative solution #3
instance Action Multiply Int where
  act (Multiply n) 1 = n
  act m1 a           = act (m1 <> Multiply a) 1
-}

{-
-- Here's another solution that satisfies the typeclass laws
-- but for practicality is not accepted by the tests
instance Action Multiply Int where
  act _ m = m
-}

-- These may also be written manualy
derive newtype instance Show Multiply
derive newtype instance Eq Multiply

-- ANCHOR: actionMultiplyString
instance Action Multiply String where
-- ANCHOR_END: actionMultiplyString
  act (Multiply n) s = power s n

instance Action m a => Action m (Array a) where
  act m arr = map (act m) arr

-- ANCHOR: Self
newtype Self m = Self m
-- ANCHOR_END: Self

instance Monoid m => Action m (Self m) where
  act m1 (Self m2) = Self (m1 <> m2)

-- These may also be written manualy
derive newtype instance Show m => Show (Self m)
derive newtype instance Eq m => Eq (Self m)

arrayHasDuplicates :: forall a. Hashable a => Array a -> Boolean
arrayHasDuplicates arr =
  let
    hashAndValEqual a b = hashEqual a b && a == b
  in
    length arr /= (length $ nubByEq hashAndValEqual arr)

-- ANCHOR: Hour
newtype Hour = Hour Int
-- ANCHOR_END: Hour

-- ANCHOR: eqHour
instance Eq Hour where
      eq (Hour n) (Hour m) = mod n 12 == mod m 12
-- ANCHOR_END: eqHour

instance Hashable Hour where
  hash (Hour h) = hash $ mod h 12
