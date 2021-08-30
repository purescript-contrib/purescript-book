module Data.GameState where

import Prelude

import Data.Coords (Coords(..), coords)
import Data.GameItem (GameItem(..))
-- ANCHOR: imports
import Data.Map as M
import Data.Set as S
-- ANCHOR_END: imports
import Data.Tuple (Tuple(..))

-- ANCHOR: GameState
newtype GameState = GameState
  { items       :: M.Map Coords (S.Set GameItem)
  , player      :: Coords
  , inventory   :: S.Set GameItem
  }
-- ANCHOR_END: GameState

instance showGameState :: Show GameState where
  show (GameState o) =
    "GameState " <>
    "{ items: "     <> show o.items <>
    ", player: "    <> show o.player <>
    ", inventory: " <> show o.inventory <>
    " }"

initialGameState :: GameState
initialGameState = GameState
  { items      : M.fromFoldable [ Tuple (coords 0 1) (S.singleton Candle)
                                , Tuple (coords 0 0) (S.singleton Matches)
                                ]
  , player     : Coords { x: 0, y: 0 }
  , inventory  : S.empty
  }
