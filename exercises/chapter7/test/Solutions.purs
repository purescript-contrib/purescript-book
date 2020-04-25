module Test.Solutions where

import Prelude
import Data.Maybe (Maybe(..))

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
combineMaybe (Just x) = Just <$> x

combineMaybe _ = pure Nothing
