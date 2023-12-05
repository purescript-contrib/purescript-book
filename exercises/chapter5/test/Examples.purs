module Test.Examples where

import Prelude
import Control.Alternative (guard)
import Data.Array (concatMap, filter, null, tail, (..), (:))
import Data.Foldable (product)
import Data.Maybe (fromMaybe)
import Data.Path (Path, ls)

-- ANCHOR: factorial
factorial :: Int -> Int
factorial 0 = 1
factorial n = n * factorial (n - 1)
-- ANCHOR_END: factorial

-- ANCHOR: fib
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)
-- ANCHOR_END: fib

-- ANCHOR: length
length :: forall a. Array a -> Int
length [] = 0
length arr = 1 + (length $ fromMaybe [] $ tail arr)
-- ANCHOR_END: length

-- ANCHOR: factors
factors :: Int -> Array (Array Int)
factors n = filter (\xs -> product xs == n) do
  i <- 1 .. n
  j <- i .. n
  pure [ i, j ]
-- ANCHOR_END: factors

-- ANCHOR: factorsV2
factorsV2 :: Int -> Array (Array Int)
factorsV2 n = filter (\xs -> product xs == n) do
  i <- 1 .. n
  j <- i .. n
  [ [ i, j ] ]
-- ANCHOR_END: factorsV2

-- ANCHOR: factorsV3
factorsV3 :: Int -> Array (Array Int)
factorsV3 n = do
  i <- 1 .. n
  j <- i .. n
  guard $ i * j == n
  pure [ i, j ]
-- ANCHOR_END: factorsV3

-- ANCHOR: factorialTailRec
factorialTailRec :: Int -> Int -> Int
factorialTailRec 0 acc = acc
factorialTailRec n acc = factorialTailRec (n - 1) (acc * n)
-- ANCHOR_END: factorialTailRec

-- ANCHOR: lengthTailRec
lengthTailRec :: forall a. Array a -> Int
lengthTailRec arr = length' arr 0
  where
  length' :: Array a -> Int -> Int
  length' [] acc = acc
  length' arr' acc = length' (fromMaybe [] $ tail arr') (acc + 1)
-- ANCHOR_END: lengthTailRec

-- ANCHOR: allFiles_signature
allFiles :: Path -> Array Path
-- ANCHOR_END: allFiles_signature
-- ANCHOR: allFiles_implementation
allFiles file = file : concatMap allFiles (ls file)
-- ANCHOR_END: allFiles_implementation

-- ANCHOR: allFiles_2
allFiles' :: Path -> Array Path
allFiles' file = file : do
  child <- ls file
  allFiles' child
-- ANCHOR_END: allFiles_2
