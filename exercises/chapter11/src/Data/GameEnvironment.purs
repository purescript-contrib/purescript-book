module Data.GameEnvironment where

-- ANCHOR: env
type PlayerName = String

newtype GameEnvironment = GameEnvironment
  { playerName    :: PlayerName
  , debugMode     :: Boolean
  }
-- ANCHOR_END: env

gameEnvironment :: PlayerName -> Boolean -> GameEnvironment
gameEnvironment playerName debugMode = GameEnvironment
  { playerName    : playerName
  , debugMode     : debugMode
  }
