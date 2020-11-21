module Example.LSystem where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Array (concatMap, foldM)
import Effect (Effect)
import Graphics.Canvas (strokePath, setStrokeStyle, lineTo, moveTo,
                        getContext2D, getCanvasElementById)
import Math as Math
import Partial.Unsafe (unsafePartial)

-- ANCHOR: lsystem_anno
lsystem :: forall a m s
         . Monad m
         => Array a
         -> (a -> Array a)
         -> (s -> a -> m s)
         -> Int
         -> s
         -> m s
-- ANCHOR_END: lsystem_anno
-- ANCHOR: lsystem_impl
lsystem init prod interpret n state = go init n
  where
-- ANCHOR_END: lsystem_impl
-- ANCHOR: lsystem_go_s_0
  go s 0 = foldM interpret state s
-- ANCHOR_END: lsystem_go_s_0
-- ANCHOR: lsystem_go_s_i
  go s i = go (concatMap prod s) (i - 1)
-- ANCHOR_END: lsystem_go_s_i

-- ANCHOR: letter
data Letter = L | R | F
-- ANCHOR_END: letter

-- ANCHOR: sentence
type Sentence = Array Letter
-- ANCHOR_END: sentence

-- ANCHOR: state
type State =
  { x :: Number
  , y :: Number
  , theta :: Number
  }
-- ANCHOR_END: state

-- ANCHOR: initial
initial :: Sentence
initial = [F, R, R, F, R, R, F, R, R]
-- ANCHOR_END: initial

-- ANCHOR: productions
productions :: Letter -> Sentence
productions L = [L]
productions R = [R]
productions F = [F, L, F, R, R, F, L, F]
-- ANCHOR_END: productions

-- ANCHOR: initialState
initialState :: State
initialState = { x: 120.0, y: 200.0, theta: 0.0 }
-- ANCHOR_END: initialState

main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas

  let
    -- ANCHOR: interpret_anno
    interpret :: State -> Letter -> Effect State
    -- ANCHOR_END: interpret_anno
    -- ANCHOR: interpretLR
    interpret state L = pure $ state { theta = state.theta - Math.tau / 6.0 }
    interpret state R = pure $ state { theta = state.theta + Math.tau / 6.0 }
    -- ANCHOR_END: interpretLR
    -- ANCHOR: interpretF
    interpret state F = do
      let x = state.x + Math.cos state.theta * 1.5
          y = state.y + Math.sin state.theta * 1.5
      moveTo ctx state.x state.y
      lineTo ctx x y
      pure { x, y, theta: state.theta }
    -- ANCHOR_END: interpretF

  setStrokeStyle ctx "#000"

-- ANCHOR: strokePath
  strokePath ctx $ lsystem initial productions interpret 5 initialState
-- ANCHOR_END: strokePath
