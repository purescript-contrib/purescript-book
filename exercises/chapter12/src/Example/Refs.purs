module Example.Refs where

import Prelude

import Effect (Effect)
import Effect.Console (logShow)
import Effect.DOM (addEventListener, querySelector)
import Effect.Ref as Ref
import Data.Foldable (for_)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (Context2D, getContext2D, getCanvasElementById,
                        rect, fillPath, translate, scale, rotate, withContext,
                        setFillStyle)
import Math as Math
import Partial.Unsafe (unsafePartial)

render :: Context2D -> Int -> Effect Unit
render ctx count = void do
  setFillStyle ctx "#FFF"

  fillPath ctx $ rect ctx
    { x: 0.0
    , y: 0.0
    , width: 600.0
    , height: 600.0
    }

  setFillStyle ctx "#0F0"

  withContext ctx do
    let scaleX = Math.sin (toNumber count * Math.tau / 8.0) + 1.5
    let scaleY = Math.sin (toNumber count * Math.tau / 12.0) + 1.5

    translate ctx { translateX: 300.0, translateY:  300.0 }
    rotate ctx (toNumber count * Math.tau / 36.0)
    scale ctx { scaleX: scaleX, scaleY: scaleY }
    translate ctx { translateX: -100.0, translateY: -100.0 }

    fillPath ctx $ rect ctx
      { x: 0.0
      , y: 0.0
      , width: 200.0
      , height: 200.0
      }

main :: Effect Unit
main = void $ unsafePartial do
  Just canvas <- getCanvasElementById "canvas"
  ctx <- getContext2D canvas

  clickCount <- Ref.new 0

  render ctx 0

  node <- querySelector "#canvas"
  for_ node $ addEventListener "click" $ void do
    logShow "Mouse clicked!"
    count <- Ref.modify (\count -> count + 1) clickCount
    render ctx count
