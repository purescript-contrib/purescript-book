module Test.NoPeeking.Solutions where

import Prelude
import Control.MonadZero (guard)
import Data.Array (catMaybes, cons, filter, find, head, last, length, nub, null, tail, (..))
import Data.Foldable (foldl)
import Data.Int (rem, quot)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Path (Path, filename, isDirectory, ls, size)
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))
import Data.Tuple (Tuple(..))
import Test.Examples

isEven :: Int -> Boolean
isEven n =
  if n < 0
    then isEven (-n)
    else if n == 0
      then true
      else not (isEven (n - 1))

oneIfEven :: Int -> Int
oneIfEven n = if isEven n then 1 else 0

countEven :: Array Int -> Int
countEven xs =
    if null xs then 0
    else oneIfEven (fromMaybe 1 $ head xs ) + countEven (fromMaybe [] $ tail xs)

squared :: Array Number -> Array Number
squared arr = map (\n -> n * n) arr

keepNonNegative :: Array Number -> Array Number
keepNonNegative arr = filter (\n -> n >= 0.0) arr

infix 4 filter as <$?>

keepNonNegativeRewrite :: Array Number -> Array Number
keepNonNegativeRewrite arr = (\n -> n >= 0.0) <$?> arr

isPrime :: Int -> Boolean
isPrime n = n > 1 && length (factors n) == 1

cartesianProduct :: ∀ a. Array a -> Array a -> Array (Array a)
cartesianProduct left right = do
  a_ <- left
  b_ <- right
  [ [ a_, b_ ] ]

triples :: Int -> Array (Array Int)
triples n = do
  i <- 1 .. n
  j <- i .. n
  k <- j .. n
  guard $ i * i + j * j == k * k
  pure [ i, j, k ]

-- | Provide the prime numbers that, multiplied together, make the argument.
primeFactors :: Int -> Array Int
primeFactors n = factorize 2 n
  where
  factorize :: Int -> Int -> Array Int
  factorize _ 1 = []
  factorize divisor dividend =
    if dividend `mod` divisor == 0 then
      cons divisor $ factorize (divisor) (dividend / divisor)
    else
      factorize (divisor + 1) dividend

allTrue :: Array Boolean -> Boolean
allTrue bools = foldl (\acc bool -> acc && bool) true bools

{-
Answer to array characterization question:
`foldl (==) false xs` returns true when `xs` contains ...
... an odd number of `false` elements.
-}
fibTailRec :: Int -> Int
fibTailRec 0 = 0
fibTailRec 1 = 1
fibTailRec n = fib' n 2 0 1
  where
  fib' :: Int -> Int -> Int -> Int -> Int
  fib' limit count n1 n2 =
    if limit == count then
      n1 + n2
    else
      fib' limit (count + 1) n2 (n1 + n2)

reverse :: ∀ a. Array a -> Array a
reverse = foldl (\xs x -> [ x ] <> xs) []

onlyFiles :: Path -> Array Path
onlyFiles path = filter (not isDirectory) (allFiles path)

allSizes :: Array Path -> Array (Tuple String Int)
allSizes paths =
  map
    ( \p -> case size p of
        Just n -> Tuple (filename p) n
        Nothing -> Tuple (filename p) 0
    )
    paths

whereIs :: Path -> String -> Maybe Path
whereIs path fileName = head $ do
  path' <- allFiles path
  child <- ls path'
  guard $ filename child == filename path' <> fileName
  pure path'

largestSmallest :: Path -> Array Path
largestSmallest path =
  let files = onlyFiles path
      maybeSizes = map size files
      maybeMax = foldl (outlier (>)) Nothing maybeSizes
      maybeMin = foldl (outlier (<)) Nothing maybeSizes
  in catMaybes $ map (findFileBySize files) $ nub $ [maybeMax, maybeMin]
  where
  outlier :: (Int -> Int -> Boolean) -> Maybe Int -> Maybe Int -> Maybe Int
  outlier criteria Nothing Nothing = Nothing
  outlier criteria (Just x) Nothing = Just x
  outlier criteria Nothing (Just x) = Just x
  outlier criteria (Just x1) (Just x2) = if criteria x1 x2 then Just x1 else Just x2
  findFileBySize :: Array Path -> Maybe Int -> Maybe Path
  findFileBySize files maybeSize = find (\file -> size file == maybeSize) files
