module Test.Random where

import Prelude
import Effect (Effect)
import Effect.Random (random)
import Effect.Console (logShow)

main :: Effect Unit
main = do
  n <- random
  logShow n
