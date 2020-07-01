module Data.Picture where

import Prelude

import Data.Foldable (foldl)
import Global as Global
import Math as Math

data Point = Point
  { x :: Number
  , y :: Number
  }

instance pointEq :: Eq Point where
  eq (Point p1) (Point p2) = p1.x == p2.x && p1.y == p2.y 

instance pointShow :: Show Point where
  show p = showPoint p

showPoint :: Point -> String
showPoint (Point { x, y }) =
  "(" <> show x <> ", " <> show y <> ")"

data Shape
  = Circle Point Number
  | Rectangle Point Number Number
  | Line Point Point
  | Text Point String

instance shapeEq :: Eq Shape where
  eq (Circle c1 r1) (Circle c2 r2) = c1 == c2 && r1 == r2 
  eq (Rectangle c1 w1 h1) (Rectangle c2 w2 h2) = c1 == c2 && w1 == w2 && h1 == h2
  eq (Line s1 e1) (Line s2 e2) = s1 == s2 && e1 == e2
  eq (Text loc1 text1) (Text loc2 text2) = loc1 == loc2 && text1 == text2
  eq _ _ = false

instance shapeShow :: Show Shape where
  show shape = showShape shape

showShape :: Shape -> String
showShape (Circle c r) =
  "Circle [center: " <> showPoint c <> ", radius: " <> show r <> "]"
showShape (Rectangle c w h) =
  "Rectangle [center: " <> showPoint c <> ", width: " <> show w <> ", height: " <> show h <> "]"
showShape (Line start end) =
  "Line [start: " <> showPoint start <> ", end: " <> showPoint end <> "]"
showShape (Text loc text) =
  "Text [location: " <> showPoint loc <> ", text: " <> show text <> "]"

origin :: Point
origin = Point { x: 0.0, y: 0.0 }

getCenter :: Shape -> Point
getCenter (Circle c r) = c
getCenter (Rectangle c w h) = c
getCenter (Line (Point s) (Point e)) = Point { x: s.x - e.x, y: s.y - e.y }
getCenter (Text loc text) = loc

type Picture = Array Shape

showPicture :: Picture -> Array String
showPicture = map showShape

data Bounds = Bounds
  { top    :: Number
  , left   :: Number
  , bottom :: Number
  , right  :: Number
  }

instance boundsEq :: Eq Bounds where
  eq (Bounds b1) (Bounds b2) = b1.left == b2.left
    && b1.top == b2.top
    && b1.right == b2.right
    && b1.bottom == b2.bottom

instance boundsShow :: Show Bounds where
  show b = showBounds b

showBounds :: Bounds -> String
showBounds (Bounds b) =
  "Bounds [top: " <> show b.top <>
  ", left: "      <> show b.left <>
  ", bottom: "    <> show b.bottom <>
  ", right: "     <> show b.right <>
  "]"

shapeBounds :: Shape -> Bounds
shapeBounds (Circle (Point { x, y }) r) = Bounds
  { top:    y - r
  , left:   x - r
  , bottom: y + r
  , right:  x + r
  }
shapeBounds (Rectangle (Point { x, y }) w h) = Bounds
  { top:    y - h / 2.0
  , left:   x - w / 2.0
  , bottom: y + h / 2.0
  , right:  x + w / 2.0
  }
shapeBounds (Line (Point p1) (Point p2)) = Bounds
  { top:    Math.min p1.y p2.y
  , left:   Math.min p1.x p2.x
  , bottom: Math.max p1.y p2.y
  , right:  Math.max p1.x p2.x
  }
shapeBounds (Text (Point { x, y }) _) = Bounds
  { top:    y
  , left:   x
  , bottom: y
  , right:  x
  }

union :: Bounds -> Bounds -> Bounds
union (Bounds b1) (Bounds b2) = Bounds
  { top:    Math.min b1.top    b2.top
  , left:   Math.min b1.left   b2.left
  , bottom: Math.max b1.bottom b2.bottom
  , right:  Math.max b1.right  b2.right
  }

intersect :: Bounds -> Bounds -> Bounds
intersect (Bounds b1) (Bounds b2) = Bounds
  { top:    Math.max b1.top    b2.top
  , left:   Math.max b1.left   b2.left
  , bottom: Math.min b1.bottom b2.bottom
  , right:  Math.min b1.right  b2.right
  }

emptyBounds :: Bounds
emptyBounds = Bounds
  { top:     Global.infinity
  , left:    Global.infinity
  , bottom: -Global.infinity
  , right:  -Global.infinity
  }

infiniteBounds :: Bounds
infiniteBounds = Bounds
  { top:    -Global.infinity
  , left:   -Global.infinity
  , bottom:  Global.infinity
  , right:   Global.infinity
  }

bounds :: Picture -> Bounds
bounds = foldl combine emptyBounds
  where
  combine :: Bounds -> Shape -> Bounds
  combine b shape = union (shapeBounds shape) b
