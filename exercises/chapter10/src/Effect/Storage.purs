module Effect.Storage where

import Prelude
import Data.Argonaut (Json)
import Effect (Effect)

foreign import setItem :: String -> String -> Effect Unit

foreign import getItem :: String -> Effect Json
