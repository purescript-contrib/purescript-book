module Test.NoPeeking.Solutions where

import Prelude
import Data.Int (rem)
import Data.Number (pi, sqrt)

-- ANCHOR: diagonal
diagonal w h = sqrt (w * w + h * h)
-- ANCHOR_END: diagonal

circleArea r = pi * r * r

leftoverCents n = rem n 100
