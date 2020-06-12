module Test.ParallelFetch where

import Prelude
import Control.Parallel (parTraverse)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (logShow)
import Test.HTTP (getUrl)

fetchPar :: Effect Unit
fetchPar =
  launchAff_ do
    let
      urls = map (\n -> "https://reqres.in/api/users/" <> show n) [ 1, 2 ]
    res <- parTraverse getUrl urls
    logShow res
