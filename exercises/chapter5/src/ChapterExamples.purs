module ChapterExamples where

import Prelude hiding (gcd)
import Data.Array (tail)
import Data.Foldable (sum)
import Data.Maybe (fromMaybe)
import Partial.Unsafe (unsafePartial)

gcd :: Int -> Int -> Int
gcd n 0 = n
gcd 0 m = m
gcd n m = if n > m
            then gcd (n - m) m
            else gcd n (m - n)

fromString :: String -> Boolean
fromString "true" = true
fromString _      = false

toString :: Boolean -> String
toString true  = "true"
toString false = "false"

gcdV2 :: Int -> Int -> Int
gcdV2 n 0 = n
gcdV2 0 n = n
gcdV2 n m | n > m     = gcdV2 (n - m) m
          | otherwise = gcdV2 n (m - n)

isEmpty :: forall a. Array a -> Boolean
isEmpty [] = true
isEmpty _ = false

takeFive :: Array Int -> Int
takeFive [0, 1, a, b, _] = a * b
takeFive _ = 0

showPerson :: { first :: String, last :: String } -> String
showPerson { first: x, last: y } = y <> ", " <> x

showPersonV2 :: { first :: String, last :: String } -> String
showPersonV2 { first, last } = last <> ", " <> first

unknownPerson :: { first :: String, last :: String }
unknownPerson = { first, last }
  where
    first = "Jane"
    last  = "Doe"

type Address = { street :: String, city :: String }

type Person = { name :: String, address :: Address }

livesInLA :: Person -> Boolean
livesInLA { address: { city: "Los Angeles" } } = true
livesInLA _ = false

sortPair :: Array Int -> Array Int
sortPair arr@[x, y]
  | x <= y = arr
  | otherwise = [y, x]
sortPair arr = arr

lzs :: Array Int -> Array Int
lzs [] = []
lzs xs = case sum xs of
           0 -> xs
           _ -> lzs (fromMaybe [] $ tail xs)

partialFunction :: Boolean -> Boolean
partialFunction = unsafePartial \true -> true

newtype Volt = Volt Number
newtype Ohm = Ohm Number
newtype Amp = Amp Number

calculateCurrent :: Volt -> Ohm -> Amp
calculateCurrent (Volt v) (Ohm r) = Amp (v / r)

battery :: Volt
battery = Volt 1.5

lightbulb :: Ohm
lightbulb = Ohm 500.0

current :: Amp
current = calculateCurrent battery lightbulb

newtype Coulomb = MakeCoulomb Number

-- These are to enable testing. Will be explained in Ch6.
derive newtype instance eqAmp :: Eq Amp
derive newtype instance showAmp :: Show Amp
