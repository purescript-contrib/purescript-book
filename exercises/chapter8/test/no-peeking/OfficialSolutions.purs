module OfficialSolutions where

import Prelude
import Data.Array
  ( foldM
  , head
  , nub
  , sort
  , tail
  )
import Data.List
  ( List(..)
  , (:)
  )
import Data.Maybe (Maybe)

possibleSums :: Array Int -> Array Int
possibleSums xs = nub $ sort $ foldM (\acc i -> [ acc, acc + i ]) 0 xs

third :: forall a. Array a -> Maybe a
third arr = do
  skip1st <- tail arr
  skip2nd <- tail skip1st
  keep3rd <- head skip2nd
  pure keep3rd

filterM :: forall a m. Monad m => (a -> m Boolean) -> List a -> m (List a)
filterM _ Nil = pure Nil

filterM f (x : xs) = do
  b <- f x
  xs' <- filterM f xs
  pure if b then x : xs' else xs'
