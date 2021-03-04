module Test.MySolutions where

import Prelude

import Data.Int (rem)
import Math (pi, sqrt)

diagonal :: Number -> Number -> Number
diagonal a b = sqrt $ a * a + b * b 

circleArea :: Number → Number
circleArea r = pi * r * r

leftoverCents :: Int → Int
leftoverCents n = rem n 100
