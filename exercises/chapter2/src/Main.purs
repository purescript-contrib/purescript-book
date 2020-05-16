module Main where

import Prelude
import Euler (answer)
import Effect.Console (log)

main = do
  log ("The answer is " <> show (answer 1000))
