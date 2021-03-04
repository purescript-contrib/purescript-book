module Test.NoPeeking.Solutions where

import Prelude
import Data.Int (rem)
import Math (e, pi, sqrt)

diagonal w h = sqrt (w * w + h * h)

circleArea r = pi * r * r

leftoverCents n = rem n 100
