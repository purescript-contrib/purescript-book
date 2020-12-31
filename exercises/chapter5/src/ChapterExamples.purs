module ChapterExamples where

import Prelude hiding (gcd)
-- ANCHOR: lzsImport
import Data.Array (tail)
import Data.Foldable (sum)
import Data.Maybe (fromMaybe)
-- ANCHOR_END: lzsImport
-- ANCHOR: unsafePartialImport
import Partial.Unsafe (unsafePartial)
-- ANCHOR_END: unsafePartialImport

-- ANCHOR: gcd
gcd :: Int -> Int -> Int
gcd n 0 = n
gcd 0 m = m
gcd n m = if n > m
            then gcd (n - m) m
            else gcd n (m - n)
-- ANCHOR_END: gcd

-- ANCHOR: fromString
fromString :: String -> Boolean
fromString "true" = true
fromString _      = false
-- ANCHOR_END: fromString

-- ANCHOR: toString
toString :: Boolean -> String
toString true  = "true"
toString false = "false"
-- ANCHOR_END: toString

-- ANCHOR: gcdV2
gcdV2 :: Int -> Int -> Int
gcdV2 n 0 = n
gcdV2 0 n = n
gcdV2 n m | n > m     = gcdV2 (n - m) m
          | otherwise = gcdV2 n (m - n)
-- ANCHOR_END: gcdV2

-- ANCHOR: isEmpty
isEmpty :: forall a. Array a -> Boolean
isEmpty [] = true
isEmpty _ = false
-- ANCHOR_END: isEmpty

-- ANCHOR: takeFive
takeFive :: Array Int -> Int
takeFive [0, 1, a, b, _] = a * b
takeFive _ = 0
-- ANCHOR_END: takeFive

-- ANCHOR: showPerson
showPerson :: { first :: String, last :: String } -> String
showPerson { first: x, last: y } = y <> ", " <> x
-- ANCHOR_END: showPerson

-- ANCHOR: showPersonV2
showPersonV2 :: { first :: String, last :: String } -> String
showPersonV2 { first, last } = last <> ", " <> first
-- ANCHOR_END: showPersonV2

-- ANCHOR: unknownPerson
unknownPerson :: { first :: String, last :: String }
unknownPerson = { first, last }
  where
    first = "Jane"
    last  = "Doe"
-- ANCHOR_END: unknownPerson

-- ANCHOR: livesInLA
type Address = { street :: String, city :: String }

type Person = { name :: String, address :: Address }

livesInLA :: Person -> Boolean
livesInLA { address: { city: "Los Angeles" } } = true
livesInLA _ = false
-- ANCHOR_END: livesInLA

-- ANCHOR: sortPair
sortPair :: Array Int -> Array Int
sortPair arr@[x, y]
  | x <= y = arr
  | otherwise = [y, x]
sortPair arr = arr
-- ANCHOR_END: sortPair

-- ANCHOR: lzs
lzs :: Array Int -> Array Int
lzs [] = []
lzs xs = case sum xs of
           0 -> xs
           _ -> lzs (fromMaybe [] $ tail xs)
-- ANCHOR_END: lzs

-- ANCHOR: partialFunction
partialFunction :: Boolean -> Boolean
partialFunction = unsafePartial \true -> true
-- ANCHOR_END: partialFunction

-- ANCHOR: electricalUnits
newtype Volt = Volt Number
newtype Ohm = Ohm Number
newtype Amp = Amp Number
-- ANCHOR_END: electricalUnits

-- ANCHOR: calculateCurrent
calculateCurrent :: Volt -> Ohm -> Amp
calculateCurrent (Volt v) (Ohm r) = Amp (v / r)

battery :: Volt
battery = Volt 1.5

lightbulb :: Ohm
lightbulb = Ohm 500.0

current :: Amp
current = calculateCurrent battery lightbulb
-- ANCHOR_END: calculateCurrent

-- ANCHOR: Coulomb
newtype Coulomb = MakeCoulomb Number
-- ANCHOR_END: Coulomb

-- These are to enable testing. Will be explained in Ch6.
derive newtype instance eqAmp :: Eq Amp
derive newtype instance showAmp :: Show Amp
