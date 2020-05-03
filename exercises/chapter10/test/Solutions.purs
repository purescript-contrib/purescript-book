module Test.Solutions where

import Prelude
import Control.Alt (alt)
import Control.Apply (lift2)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, jsonParser)
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJson)
import Data.Argonaut.Encode.Generic.Rep (genericEncodeJson)
import Data.Either (Either(..))
import Data.Foldable (foldr)
import Data.Function.Uncurried (Fn3)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Eq (genericEq)
import Data.Generic.Rep.Show (genericShow)
import Data.Map (Map)
import Data.Pair (Pair(..))
import Data.Set (Set)
import Test.Examples (Complex, Quadratic)

foreign import volumeFn :: Fn3 Number Number Number Number

foreign import volumeArrow :: Number -> Number -> Number -> Number

foreign import cumulativeSumsComplex :: Array Complex -> Array Complex

foreign import quadraticRootsImpl :: (forall a. a -> a -> Pair a) -> Quadratic -> Pair Complex

quadraticRoots :: Quadratic -> Pair Complex
quadraticRoots poly = quadraticRootsImpl Pair poly

foreign import valuesOfMapJson :: Json -> Json

valuesOfMap :: Map String Int -> Either String (Set Int)
valuesOfMap = encodeJson >>> valuesOfMapJson >>> decodeJson

valuesOfMapGeneric ::
  forall k v.
  EncodeJson k =>
  EncodeJson v =>
  DecodeJson v =>
  Ord k =>
  Ord v =>
  Map k v ->
  Either String (Set v)
valuesOfMapGeneric = encodeJson >>> valuesOfMapJson >>> decodeJson

foreign import quadraticRootsSetJson :: Json -> Json

quadraticRootsSet :: Quadratic -> Either String (Set Complex)
quadraticRootsSet = encodeJson >>> quadraticRootsSetJson >>> decodeJson

foreign import quadraticRootsSafeJson :: Json -> Json

newtype WrapPair a
  = WrapPair (Pair a)

instance decodeJsonWrapPair :: DecodeJson a => DecodeJson (WrapPair a) where
  decodeJson j = do
    decoded <- decodeJson j
    case decoded of
      [ a, b ] -> map WrapPair $ lift2 Pair (decodeJson a) (decodeJson b)
      _ -> Left "Couldn't decode WrapPair"

quadraticRootsSafeWrap :: Quadratic -> Either String (WrapPair Complex)
quadraticRootsSafeWrap = encodeJson >>> quadraticRootsSafeJson >>> decodeJson

quadraticRootsSafe :: Quadratic -> Either String (Pair Complex)
quadraticRootsSafe = quadraticRootsSafeWrap >>> map (\(WrapPair p) -> p)

decodeArray2D :: String -> Either String (Array (Array Int))
decodeArray2D str = do
  j <- jsonParser str
  decodeJson j

data Tree a
  = Leaf a
  | Branch (Tree a) (Tree a)

derive instance genericTree :: Generic (Tree a) _

instance encodeJsonTree :: EncodeJson a => EncodeJson (Tree a) where
  encodeJson t = genericEncodeJson t

instance decodeJsonTree :: DecodeJson a => DecodeJson (Tree a) where
  decodeJson t = genericDecodeJson t

instance eqTree :: Eq a => Eq (Tree a) where
  eq t = genericEq t

instance showTree :: Show a => Show (Tree a) where
  show t = genericShow t

data IntOrString
  = IntOrString_Int Int
  | IntOrString_String String

instance encodeJsonIntOrString :: EncodeJson IntOrString where
  encodeJson (IntOrString_Int i) = encodeJson i
  encodeJson (IntOrString_String s) = encodeJson s

instance decodeJsonIntOrString :: DecodeJson IntOrString where
  decodeJson j =
    foldr alt (Left "Could not decode IntOrString")
      [ map IntOrString_Int $ decodeJson j
      , map IntOrString_String $ decodeJson j
      ]

derive instance genericIntOrString :: Generic IntOrString _

instance eqIntOrString :: Eq IntOrString where
  eq = genericEq

instance showIntOrString :: Show IntOrString where
  show = genericShow
