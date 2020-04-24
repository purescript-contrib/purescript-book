module Test.Solutions where

import Prelude
import Data.Array ((:), (..))
import Data.Path (Path, ls)
import Control.MonadZero (guard)

factors :: Int -> Array (Array Int)
factors n = do
  i <- 1 .. n
  j <- i .. n
  guard $ i * j == n
  pure [ i, j ]

-- Section for : A Virtual Filesystem exercise
allFiles :: Path -> Array Path
allFiles file =
  file
    : do
        child <- ls file
        allFiles child
