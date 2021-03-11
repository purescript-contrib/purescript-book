module Test.MySolutions where

import Prelude

import Control.Alternative (guard)
import Data.Array (filter, find, reverse, uncons, (..), (:))
import Data.Maybe (Maybe(..))
import Data.Newtype (overF)
import Test.Examples (factors)

-- Note to reader: Add your solutions to this file
isEven :: Int -> Boolean
isEven n = case n of
  0 -> true
  1 -> false
  _ -> isEven (n - 2)

countEven :: Array Int -> Int
countEven a = case uncons a of
  Just { head: x, tail: xs } -> (if isEven x then 1 else 0) + countEven xs
  _ -> 0

squared :: Array Number -> Array Number
squared = map (\x -> x * x)

keepNonNegative :: Array Number -> Array Number
keepNonNegative = filter (\x -> x >= 0.0)

infixl 4 filter as <$?>

keepNonNegativeRewrite :: Array Number -> Array Number
keepNonNegativeRewrite xs = (\x -> x >= 0.0) <$?> xs

isPrime :: Int -> Boolean
isPrime n = n > 1 && factors n == [[1, n]]

cartesianProduct :: forall a. Array a -> Array a -> Array (Array a)
cartesianProduct xs ys = do
  x <- xs
  y <- ys
  pure [x, y]

triples :: Int -> Array (Array Int)
triples n = do
  a <- 1 .. n
  b <- a .. n
  c <- 1 .. n
  guard $ a * a + b * b == c * c && c <= n
  pure [a, b, c]

primes :: Int -> Array Int
primes max = filter isPrime $ 2 : filter (not <<< isEven) (3 .. max)

divisibleBy :: Int -> Int -> Boolean
divisibleBy a b = a `mod` b == 0

factorize :: Int -> Array Int
factorize n = case n of
  1 -> []
  _ -> if isPrime n then [n] else case (find (n `divisibleBy` _) $ reverse $ primes n) of
    Just i -> i : (factorize $ n / i)
    _ -> []
