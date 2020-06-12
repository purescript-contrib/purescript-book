module Test.Examples where

import Prelude
import Control.MonadZero (guard)
import Data.Array (concatMap, filter, null, tail, (..), (:))
import Data.Foldable (product)
import Data.Maybe (fromMaybe)
import Data.Path (Path, ls)

fact :: Int -> Int
fact 0 = 1

fact n = n * fact (n - 1)

fib :: Int -> Int
fib 0 = 1

fib 1 = 1

fib n = fib (n - 1) + fib (n - 2)

length :: forall a. Array a -> Int
length arr =
  if null arr then
    0
  else
    1 + (length $ fromMaybe [] $ tail arr)

factors :: Int -> Array (Array Int)
factors n =
  filter
    (\xs -> product xs == n) do
    i <- 1 .. n
    j <- i .. n
    pure [ i, j ]

factorsV2 :: Int -> Array (Array Int)
factorsV2 n =
  filter (\xs -> product xs == n) do
    i <- 1 .. n
    j <- i .. n
    [ [ i, j ] ]

factorsV3 :: Int -> Array (Array Int)
factorsV3 n = do
  i <- 1 .. n
  j <- i .. n
  guard $ i * j == n
  pure [ i, j ]

factTailRec :: Int -> Int -> Int
factTailRec 0 acc = acc

factTailRec n acc = factTailRec (n - 1) (acc * n)

lengthTailRec :: forall a. Array a -> Int
lengthTailRec arr = length' arr 0
  where
  length' :: Array a -> Int -> Int
  length' arr' acc =
    if null arr' then
      acc
    else
      length' (fromMaybe [] $ tail arr') (acc + 1)

allFiles :: Path -> Array Path
allFiles file = file : concatMap allFiles (ls file)

allFiles' :: Path -> Array Path
allFiles' file =
  file
    : do
        child <- ls file
        allFiles' child
