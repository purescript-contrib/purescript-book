module Test.NoPeeking.Solutions where

import Prelude

import Control.Alt (alt)
import Control.Apply (lift2)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, JsonDecodeError(..), decodeJson, encodeJson, jsonParser, printJsonDecodeError)
import Data.Argonaut.Decode.Generic (genericDecodeJson)
import Data.Argonaut.Encode.Generic (genericEncodeJson)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Eq.Generic (genericEq)
import Data.Foldable (foldr)
import Data.Function.Uncurried (Fn3)
import Data.Generic.Rep (class Generic)
import Data.Map (Map)
import Data.Maybe (Maybe(..))
import Data.Pair (Pair(..))
import Data.Set (Set)
import Data.Show.Generic (genericShow)
import Test.Examples (Complex, Quadratic, Undefined)

foreign import volumeFn :: Fn3 Number Number Number Number

foreign import volumeArrow :: Number -> Number -> Number -> Number

foreign import cumulativeSumsComplex :: Array Complex -> Array Complex

foreign import quadraticRootsImpl :: (forall a. a -> a -> Pair a) -> Quadratic -> Pair Complex

quadraticRoots :: Quadratic -> Pair Complex
quadraticRoots poly = quadraticRootsImpl Pair poly

foreign import toMaybeImpl :: forall a. (forall x. x -> Maybe x) -> (forall x. Maybe x) -> Undefined a -> Maybe a

toMaybe :: forall a. Undefined a -> Maybe a
toMaybe = toMaybeImpl Just Nothing

foreign import valuesOfMapJson :: Json -> Json

valuesOfMap :: Map String Int -> Either JsonDecodeError (Set Int)
valuesOfMap = encodeJson >>> valuesOfMapJson >>> decodeJson

valuesOfMapGeneric ::
  forall k v.
  EncodeJson k =>
  EncodeJson v =>
  DecodeJson v =>
  Ord k =>
  Ord v =>
  Map k v ->
  Either JsonDecodeError (Set v)
valuesOfMapGeneric = encodeJson >>> valuesOfMapJson >>> decodeJson

foreign import quadraticRootsSetJson :: Json -> Json

quadraticRootsSet :: Quadratic -> Either JsonDecodeError (Set Complex)
quadraticRootsSet = encodeJson >>> quadraticRootsSetJson >>> decodeJson

foreign import quadraticRootsSafeJson :: Json -> Json

newtype WrapPair a
  = WrapPair (Pair a)

instance decodeJsonWrapPair :: DecodeJson a => DecodeJson (WrapPair a) where
  decodeJson j = do
    decoded <- decodeJson j
    case decoded of
      [ a, b ] -> map WrapPair $ lift2 Pair (decodeJson a) (decodeJson b)
      [ ] -> Left $ AtIndex 0 MissingValue
      [ a ] -> Left $ AtIndex 1 MissingValue
      _ -> Left $ AtIndex 2 $ UnexpectedValue j

quadraticRootsSafeWrap :: Quadratic -> Either JsonDecodeError (WrapPair Complex)
quadraticRootsSafeWrap = encodeJson >>> quadraticRootsSafeJson >>> decodeJson

quadraticRootsSafe :: Quadratic -> Either JsonDecodeError (Pair Complex)
quadraticRootsSafe = quadraticRootsSafeWrap >>> map (\(WrapPair p) -> p)

parseAndDecodeArray2D :: String -> Either String (Array (Array Int))
parseAndDecodeArray2D str = do
  j <- jsonParser str
  lmap printJsonDecodeError $ decodeJson j

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
    foldr alt (Left $ TypeMismatch "Not Int or String")
      [ map IntOrString_Int $ decodeJson j
      , map IntOrString_String $ decodeJson j
      ]

derive instance genericIntOrString :: Generic IntOrString _

instance eqIntOrString :: Eq IntOrString where
  eq = genericEq

instance showIntOrString :: Show IntOrString where
  show = genericShow
