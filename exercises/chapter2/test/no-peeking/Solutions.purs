module Test.NoPeeking.Solutions where

import Prelude
import Global (readFloat)
import Math (e, pi, sqrt)

diagonal w h = sqrt (w * w + h * h)

circleArea r = pi * r * r

addE s = readFloat s + e
