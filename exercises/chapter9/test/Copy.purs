module Test.Copy where

import Prelude
import Data.Either (Either(..))
import Effect.Aff (Aff, attempt, message)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.Path (FilePath)

copyFile :: FilePath -> FilePath -> Aff Unit
copyFile file1 file2 = do
  my_data <- readTextFile UTF8 file1
  writeTextFile UTF8 file2 my_data

main :: Aff Unit
main = do
  result <- attempt $ copyFile "file1.txt" "file2.txt"
  case result of
    Left e -> log $ "There was a problem with copyFile: " <> message e
    _ -> pure unit

-- Main is unused, but will eventually be linked to in text
