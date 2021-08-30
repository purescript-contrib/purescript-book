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
-- ANCHOR: import_RL
import Node.ReadLine as RL
-- ANCHOR_END: import_RL
import Options.Applicative ((<**>))
import Options.Applicative as OP

-- ANCHOR: runGame_sig
runGame :: GameEnvironment -> Effect Unit
-- ANCHOR_END: runGame_sig
-- ANCHOR: runGame_interface
runGame env = do
  interface <- RL.createConsoleInterface RL.noCompletion
-- ANCHOR_END: runGame_interface
-- ANCHOR: runGame_prompt
  RL.setPrompt "> " interface
-- ANCHOR_END: runGame_prompt

  let
-- ANCHOR: runGame_lineHandler
    lineHandler :: GameState -> String -> Effect Unit
    lineHandler currentState input = do
      case runRWS (game (split (wrap " ") input)) env currentState of
        RWSResult state _ written -> do
          for_ written log
          RL.setLineHandler (lineHandler state) $ interface
      RL.prompt interface
      pure unit
-- ANCHOR_END: runGame_lineHandler

-- ANCHOR: runGame_attach_handler
  RL.setLineHandler (lineHandler initialGameState) interface
  RL.prompt interface
-- ANCHOR_END: runGame_attach_handler

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
