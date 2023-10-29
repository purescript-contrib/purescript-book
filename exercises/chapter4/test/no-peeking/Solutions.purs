module Test.NoPeeking.Solutions where

import Prelude

import ChapterExamples (Amp(..), Volt(..), Coulomb(..))
import Data.Maybe (Maybe(Just, Nothing))
import Data.Person (Person)
import Data.Picture
  ( Bounds
  , Picture
  , Point
  , Shape(Circle, Rectangle, Line, Text)
  , bounds
  , getCenter
  , intersect
  , origin
  )
import Data.Picture as DataP
import Data.Number as Number

factorial :: Int -> Int
factorial 0 = 1
factorial n = n * factorial (n - 1)

binomial :: Int -> Int -> Int
binomial _ 0 = 1
binomial 0 _ = 0
binomial n k | n < k = 0
  | otherwise = factorial n / (factorial k * (factorial (n - k)))

pascal :: Int -> Int -> Int
pascal _ 0 = 1
pascal 0 _ = 0
pascal n k
  = pascal (n-1) k + pascal (n - 1) (k - 1)
{-
Most general type for sameCity and livesInLA functions taking into account row polymorphism:

sameCity
  :: forall r1 s1. { address :: { city :: String | s1 } | r1 }
  -> forall r2 s2. { address :: { city :: String | s2 } | r2 }
  -> Boolean

livesInLA
  :: forall r s. { address :: { city :: String | s } | r }
  -> Boolean
-}

sameCity :: Person -> Person -> Boolean
sameCity { address: { city: c1 } } { address: { city: c2 } }
  | c1 == c2 = true
  | otherwise = false

fromSingleton :: forall a. a -> Array a -> a
fromSingleton a [b] = b
fromSingleton a _ = a

circleAtOrigin :: Shape
circleAtOrigin = Circle origin 10.0

centerShape :: Shape -> Shape
centerShape (Circle c r) = Circle origin r
centerShape (Rectangle c w h) = Rectangle origin w h
centerShape line@(Line s e) = Line (s - delta) (e - delta)
  where
  delta = getCenter line
centerShape (Text loc text) = Text origin text

scaleShape :: Number -> Shape -> Shape
scaleShape i (Circle c r) = Circle c (r * i)
scaleShape i (Rectangle c w h) = Rectangle c (w * i) (h * i)
scaleShape i (Line s e) = Line (s * scale) (e * scale)
  where
  scale = {x: i, y: i}
scaleShape i text = text

doubleScaleAndCenter :: Shape -> Shape
doubleScaleAndCenter = centerShape <<< scaleShape 2.0

shapeText :: Shape -> Maybe String
shapeText (Text _ text) = Just text
shapeText _ = Nothing

area :: Shape -> Number
area (Circle _ r) = Number.pi * r * r
area (Rectangle _ h w) = h * w
area _ = 0.0

{-
The real solution for this exercise just requires adding the
`Clipped` constructor to `Shape` directly in `Picture.purs`.
But we're using `ShapeExt` here as a workaround so we don't need to edit
code outside of this file.
-}
data ShapeExt
  = Clipped Picture Point Number Number
  | Shape Shape

{-
Your solution should edit `shapeBounds` in `Picture.purs`.
-}
shapeBounds :: ShapeExt -> Bounds
shapeBounds (Clipped pic pt w h) = intersect (bounds pic) (DataP.shapeBounds (Rectangle pt w h))
shapeBounds (Shape shape) = DataP.shapeBounds shape

newtype Watt = Watt Number

calculateWattage :: Amp -> Volt -> Watt
calculateWattage (Amp i) (Volt v) = Watt $ i * v
