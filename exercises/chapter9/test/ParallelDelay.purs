module Test.ParallelDelay where

import Prelude
import Control.Parallel (parSequence_)
import Data.Array (replicate)
import Data.Foldable (sequence_)
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, launchAff_)

delayArray :: Array (Aff Unit)
delayArray = replicate 100 $ delay $ Milliseconds 10.0

seqDelay :: Effect Unit
seqDelay = launchAff_ $ sequence_ delayArray

parDelay :: Effect Unit
parDelay = launchAff_ $ parSequence_ delayArray
