module Test.HTTP where

-- ANCHOR: getUrl
import Prelude
import Affjax.Node as AN
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..))
import Effect.Aff (Aff)

getUrl :: String -> Aff String
getUrl url = do
  result <- AN.get ResponseFormat.string url
  pure case result of
    Left err -> "GET /api response failed to decode: " <> AN.printError err
    Right response -> response.body
-- ANCHOR_END: getUrl
