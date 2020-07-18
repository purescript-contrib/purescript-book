module Test.NoPeeking.Solutions where

import Prelude

import Data.Array (foldM, head, nub, sort, tail)
import Data.List (List(..), (:))
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Exception (error, throwException)

third :: forall a. Array a -> Maybe a
third arr = do
  skip1st <- tail arr
  skip2nd <- tail skip1st
  head skip2nd

possibleSums :: Array Int -> Array Int
possibleSums xs = nub $ sort $ foldM (\acc i -> [ acc, acc + i ]) 0 xs

filterM :: forall a m. Monad m => (a -> m Boolean) -> List a -> m (List a)
filterM _ Nil = pure Nil

filterM f (x : xs) = do
  b <- f x
  xs' <- filterM f xs
  pure if b then x : xs' else xs'

exceptionDivide :: Int -> Int -> Effect Int
exceptionDivide _ 0 = throwException $ error "div zero"

exceptionDivide a b = pure $ a / b