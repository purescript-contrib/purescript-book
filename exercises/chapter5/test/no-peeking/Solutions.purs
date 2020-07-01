module Test.NoPeeking.Solutions where

import Prelude

import Data.Maybe (Maybe(Just, Nothing))
import Data.Person (Person)
import Data.Picture 
  ( Bounds
  , Picture
  , Point(Point)
  , Shape(Circle, Rectangle, Line, Text)
  , origin
  , bounds
  , intersect
  )
import Data.Picture as DataP
import Math as Math

factorial :: Int -> Int
factorial 0 = 1
factorial n = n * factorial (n - 1)

binomial :: Int -> Int -> Int
binomial n 0 = 1
binomial n m 
  | n == m = 1
  | otherwise = factorial n / (factorial m * (factorial (n - m)))

sameCity :: Person -> Person -> Boolean
sameCity { address: { city: c1 } } { address: { city: c2 } }
  | c1 == c2 = true
  | otherwise = false

fromSingleton :: forall a. a -> Array a -> a
fromSingleton a [] = a
fromSingleton a [b] = b
fromSingleton a _ = a

circleAtOrigin :: Shape
circleAtOrigin = Circle origin 10.0

centerShape :: Shape -> Shape
centerShape (Circle c r) = Circle origin r
centerShape (Rectangle c w h) = Rectangle origin w h
centerShape (Line (Point s) (Point e)) = 
  (Line 
    (Point { x: s.x - deltaX, y: s.y - deltaY })
    (Point { x: e.x - deltaX, y: e.y - deltaY })
  )
  where
  deltaX = (e.x + s.x) / 2.0
  deltaY = (e.y + s.y) / 2.0
centerShape (Text loc text) = Text origin text

scaleShape :: Number -> Shape -> Shape
scaleShape i (Circle c r) = Circle c (r * i)
scaleShape i (Rectangle c w h) = Rectangle c (w * i) (h * i)
scaleShape i (Line (Point s) (Point e)) = 
  (Line 
    (Point { x: s.x * i, y: s.y * i })
    (Point { x: e.x * i, y: e.y * i })
  )
scaleShape i text = text

doubleScaleAndCenter :: Shape -> Shape
doubleScaleAndCenter = centerShape <<< scaleShape 2.0

shapeText :: Shape -> Maybe String
shapeText (Text _ text) = Just text
shapeText _ = Nothing

area :: Shape -> Number
area (Circle _ r) = Math.pi * r * r
area (Rectangle _ h w) = h * w
area _ = 0.0

data ShapeExt = Clipped Picture Point Number Number
  | Shape Shape

shapeBounds :: ShapeExt -> Bounds
shapeBounds (Clipped pic pt w h) = intersect (bounds pic) (DataP.shapeBounds (Rectangle pt w h))
shapeBounds (Shape shape) = DataP.shapeBounds shape
