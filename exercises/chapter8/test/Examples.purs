module Test.Examples where

import Prelude
import Control.Plus (empty)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Array ((..))

{-| Monads and Do Notation -}
countThrows :: Int -> Array (Array Int)
countThrows n = do
  x <- 1 .. 6
  y <- 1 .. 6
  if x + y == n then
    pure [ x, y ]
  else
    empty

{-| Folding With Monads -}
foldM ::
  forall m a b.
  Monad m =>
  (a -> b -> m a) ->
  a ->
  List b ->
  m a
foldM _ a Nil = pure a

foldM f a (b : bs) = do
  a' <- f a b
  foldM f a' bs

safeDivide :: Int -> Int -> Maybe Int
safeDivide _ 0 = Nothing

safeDivide a b = Just (a / b)
