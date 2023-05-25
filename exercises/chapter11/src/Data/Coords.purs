module Data.Coords where

import Prelude

newtype Coords = Coords
  { x :: Int
  , y :: Int
  }

instance Show Coords where
  show (Coords p) = "Coords " <>
                    "{ x: " <> show p.x <>
                    ", y: " <> show p.y <>
                    " }"

derive instance Eq Coords
derive instance Ord Coords

coords :: Int -> Int -> Coords
coords x y = Coords { x: x, y: y }

prettyPrintCoords :: Coords -> String
prettyPrintCoords (Coords p) = "(" <> show p.x <> ", " <> show p.y <> ")"
