module Test.NoPeeking.Solutions where

import Prelude
import Affjax as AX
import Affjax.ResponseFormat as AXRF
import Affjax.Node as AN
import Control.Parallel (parOneOf, parTraverse)
import Data.Array (concat, (:))
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), length, split)
import Data.Traversable (fold, traverse)
import Effect.Aff (Aff, Error, Milliseconds(..), attempt, delay)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.Path (FilePath)
import Node.Path as Path

-- Group: Async PS
concatenateFiles :: FilePath -> FilePath -> FilePath -> Aff Unit
concatenateFiles f1 f2 fConcat = do
  f1Data <- readTextFile UTF8 f1
  f2Data <- readTextFile UTF8 f2
  writeTextFile UTF8 fConcat $ f1Data <> f2Data

concatenateMany :: Array FilePath -> FilePath -> Aff Unit
concatenateMany arr out = do
  arrContents <- traverse (readTextFile UTF8) arr
  writeTextFile UTF8 out $ fold arrContents

countCharacters :: FilePath -> Aff (Either Error Int)
countCharacters file =
  attempt do
    contents <- readTextFile UTF8 file
    pure $ length contents

-- Group: HTTP
writeGet :: String -> FilePath -> Aff Unit
writeGet url out = do
  result <- AN.get AXRF.string url
  let
    str = case result of
      Left err -> "GET /api response failed to decode: " <> AX.printError err
      Right response -> response.body
  writeTextFile UTF8 out str

-- Group: Parallel
concatenateManyParallel :: Array FilePath -> FilePath -> Aff Unit
concatenateManyParallel arr out = do
  arrContents <- parTraverse (readTextFile UTF8) arr
  writeTextFile UTF8 out $ fold arrContents

getWithTimeout :: Number -> String -> Aff (Maybe String)
getWithTimeout ms url =
  parOneOf
    [ AN.get AXRF.string url <#> hush <#> map _.body
    , delay (Milliseconds ms) $> Nothing
    ]

recurseFiles :: FilePath -> Aff (Array FilePath)
recurseFiles file = do
  contents <- readTextFile UTF8 file
  case contents of
    "" -> pure [ file ]
    c -> do
      let
        dir = Path.dirname file

        files = split (Pattern "\n") contents

        filesFromRoot = map (\f -> Path.concat [ dir, f ]) files
      arrarr <- parTraverse recurseFiles filesFromRoot
      pure $ file : concat arrarr
