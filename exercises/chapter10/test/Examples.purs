module Test.Examples where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Argonaut (Json, JsonDecodeError, decodeJson, encodeJson)
import Data.Either (Either)
import Data.Function.Uncurried (Fn2, mkFn2, runFn2)
import Data.Map (Map)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn2)

foreign import square :: Number -> Number

-- ANCHOR: diagonal
foreign import diagonal :: Number -> Number -> Number
-- ANCHOR_END: diagonal

-- ANCHOR: diagonal_arrow
foreign import diagonalArrow :: Number -> Number -> Number
-- ANCHOR_END: diagonal_arrow

-- ANCHOR: diagonal_uncurried
foreign import diagonalUncurried :: Fn2 Number Number Number
-- ANCHOR_END: diagonal_uncurried

-- ANCHOR: uncurried_add
uncurriedAdd :: Fn2 Int Int Int
uncurriedAdd = mkFn2 \n m -> m + n
-- ANCHOR_END: uncurried_add

-- ANCHOR: uncurried_sum
uncurriedSum :: Int
uncurriedSum = runFn2 uncurriedAdd 3 10
-- ANCHOR_END: uncurried_sum

-- ANCHOR: curried_add
curriedAdd :: Int -> Int -> Int
curriedAdd n m = m + n

curriedSum :: Int
curriedSum = curriedAdd 3 10
-- ANCHOR_END: curried_add

foreign import cumulativeSums :: Array Int -> Array Int

type Complex
  = { real :: Number
    , imag :: Number
    }

foreign import addComplex :: Complex -> Complex -> Complex

foreign import maybeHeadImpl :: forall a. (forall x. x -> Maybe x) -> (forall x. Maybe x) -> Array a -> Maybe a

maybeHead :: forall a. Array a -> Maybe a
maybeHead arr = maybeHeadImpl Just Nothing arr

foreign import data Undefined :: Type -> Type

foreign import undefinedHead :: forall a. Array a -> Undefined a

foreign import isUndefined :: forall a. Undefined a -> Boolean

isEmpty :: forall a. Array a -> Boolean
isEmpty = isUndefined <<< undefinedHead

foreign import unsafeHead :: forall a. Array a -> a

type Quadratic
  = { a :: Number
    , b :: Number
    , c :: Number
    }

foreign import boldImpl :: forall a. (a -> String) -> a -> String

bold :: forall a. Show a => a -> String
bold = boldImpl show

foreign import showEqualityImpl :: forall a. (a -> a -> Boolean) -> (a -> String) -> a -> a -> String

showEquality :: forall a. Eq a => Show a => a -> a -> String
showEquality = showEqualityImpl eq show

foreign import yellImpl :: forall a. (a -> String) -> a -> Effect Unit

yell :: forall a. Show a => a -> Effect Unit
yell = yellImpl show

foreign import diagonalLog :: EffectFn2 Number Number Number

foreign import sleepImpl :: Int -> Effect (Promise Unit)

sleep :: Int -> Aff Unit
sleep = sleepImpl >>> toAffE

foreign import diagonalAsyncImpl :: Int -> Number -> Number -> Effect (Promise Number)

diagonalAsync :: Int -> Number -> Number -> Aff Number
diagonalAsync i x y = toAffE $ diagonalAsyncImpl i x y

foreign import cumulativeSumsBroken :: Array Int -> Array Int

foreign import addComplexBroken :: Complex -> Complex -> Complex

foreign import cumulativeSumsJson :: Array Int -> Json

-- ANCHOR: cumulativeSumsDecoded
cumulativeSumsDecoded :: Array Int -> Either JsonDecodeError (Array Int)
cumulativeSumsDecoded arr = decodeJson $ cumulativeSumsJson arr
-- ANCHOR_END: cumulativeSumsDecoded

foreign import addComplexJson :: Complex -> Complex -> Json

-- ANCHOR: addComplexDecoded
addComplexDecoded :: Complex -> Complex -> Either JsonDecodeError Complex
addComplexDecoded a b = decodeJson $ addComplexJson a b
-- ANCHOR_END: addComplexDecoded

-- ANCHOR: mapSetFooJson
foreign import mapSetFooJson :: Json -> Json

mapSetFoo :: Map String Int -> Either JsonDecodeError (Map String Int)
mapSetFoo = encodeJson >>> mapSetFooJson >>> decodeJson
-- ANCHOR_END: mapSetFooJson

{-
These versions always point to either the working or broken versions
to enable automated testing.
The examples accompanying the text are meant to be swapped
between versions by the reader.
-}
foreign import cumulativeSumsJsonBroken :: Array Int -> Json

cumulativeSumsDecodedBroken :: Array Int -> Either JsonDecodeError (Array Int)
cumulativeSumsDecodedBroken = cumulativeSumsJsonBroken >>> decodeJson

foreign import addComplexJsonBroken :: Complex -> Complex -> Json

addComplexDecodedBroken :: Complex -> Complex -> Either JsonDecodeError Complex
addComplexDecodedBroken a b = decodeJson $ addComplexJsonBroken a b

foreign import cumulativeSumsJsonWorking :: Array Int -> Json

cumulativeSumsDecodedWorking :: Array Int -> Either JsonDecodeError (Array Int)
cumulativeSumsDecodedWorking = cumulativeSumsJsonWorking >>> decodeJson

foreign import addComplexJsonWorking :: Complex -> Complex -> Json

addComplexDecodedWorking :: Complex -> Complex -> Either JsonDecodeError Complex
addComplexDecodedWorking a b = decodeJson $ addComplexJsonWorking a b
