module Main where

import Prelude

import Control.Monad.RWS (RWSResult(..), runRWS)
import Data.Foldable (fold, for_)
import Data.GameEnvironment (GameEnvironment, gameEnvironment)
import Data.GameState (GameState, initialGameState)
import Data.Newtype (wrap)
import Data.String (split)
import Effect (Effect)
import Effect.Console (log)
import Game (game)
import Node.ReadLine as RL
import Options.Applicative ((<**>))
import Options.Applicative as OP

runGame :: GameEnvironment -> Effect Unit
runGame env = do
  interface <- RL.createConsoleInterface RL.noCompletion
  RL.setPrompt "> " interface

  let
    lineHandler :: GameState -> String -> Effect Unit
    lineHandler currentState input = do
      case runRWS (game (split (wrap " ") input)) env currentState of
        RWSResult state _ written -> do
          for_ written log
          RL.setLineHandler (lineHandler state) $ interface
      RL.prompt interface
      pure unit

  RL.setLineHandler (lineHandler initialGameState) interface
  RL.prompt interface

  pure unit

main :: Effect Unit
-- ANCHOR: main
main = OP.customExecParser prefs argParser >>= runGame 
-- ANCHOR_END: main
  where

-- ANCHOR: argParser
  argParser :: OP.ParserInfo GameEnvironment
  argParser = OP.info (env <**> OP.helper) parserOptions
-- ANCHOR_END: argParser

-- ANCHOR: env
  env :: OP.Parser GameEnvironment
  env = gameEnvironment <$> player <*> debug

  player :: OP.Parser String
  player = OP.strOption $ fold 
    [ OP.long "player"
    , OP.short 'p'
    , OP.metavar "<player name>"
    , OP.help "The player's name <String>"
    ]

  debug :: OP.Parser Boolean
  debug = OP.switch $ fold 
    [ OP.long "debug"
    , OP.short 'd'
    , OP.help "Use debug mode"
    ]
-- ANCHOR_END: env

  prefs = OP.prefs OP.showHelpOnEmpty
-- ANCHOR: parserOptions
  parserOptions = fold 
    [ OP.fullDesc
    , OP.progDesc "Play the game as <player name>"
    , OP.header "Monadic Adventures! A game to learn monad transformers" 
    ]
-- ANCHOR_END: parserOptions