module Example.Rectangle where

import Prelude

import Effect (Effect)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (rect, fillPath, setFillStyle, getContext2D,
                        getCanvasElementById)
import Partial.Unsafe (unsafePartial)

-- ANCHOR: main
main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas
-- ANCHOR_END: main

-- ANCHOR: setFillStyle
  setFillStyle ctx "#00F"
-- ANCHOR_END: setFillStyle

-- ANCHOR: fillPath
  fillPath ctx $ rect ctx
    { x: 250.0
    , y: 250.0
    , width: 100.0
    , height: 100.0
    }
-- ANCHOR_END: fillPath
