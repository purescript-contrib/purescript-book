module Test.Starter where

import Prelude
import Data.AddressBook
  ( Address
  , PhoneNumber
  )

lift3 ::
  forall a b c d f.
  Apply f =>
  (a -> b -> c -> d) ->
  f a ->
  f b ->
  f c ->
  f d
lift3 f x y z = f <$> x <*> y <*> z

data Tree a
  = Leaf
  | Branch (Tree a) a (Tree a)
