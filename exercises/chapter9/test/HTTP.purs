module Test.HTTP where

import Prelude
import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..))
import Effect.Aff (Aff)

getUrl :: String -> Aff String
getUrl url = do
  result <- AX.get ResponseFormat.string url
  pure case result of
    Left err -> "GET /api response failed to decode: " <> AX.printError err
    Right response -> response.body
