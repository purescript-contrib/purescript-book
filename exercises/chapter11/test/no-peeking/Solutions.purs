module Test.NoPeeking.Solutions where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT, throwError)
import Control.Monad.Reader (Reader, ReaderT, ask, lift, local, runReader, runReaderT)
import Control.Monad.State (State, StateT, get, put, execState, modify_)
import Control.Monad.Writer (Writer, WriterT, tell, runWriter, execWriterT)
import Data.Array (some)
import Data.Foldable (fold, foldl)
import Data.GameState (GameState(..))
import Data.Identity (Identity)
import Data.List ((:))
import Data.List as L
import Data.Map as M
import Data.Maybe (Maybe(..))
import Data.Monoid (power)
import Data.Monoid.Additive (Additive(..))
import Data.Newtype (unwrap)
import Data.Set as S
import Data.String (joinWith)
import Data.String.CodeUnits (stripPrefix, toCharArray)
import Data.String.Pattern (Pattern(..))
import Data.Traversable (sequence, traverse_)
import Data.Tuple (Tuple)
import Game (Game)

--

testParens :: String -> Boolean
testParens str =
  let
    openTally :: Char -> Int -> Int
    -- Open parens only considered if not already in deficit.
    -- No recovery from too-many closed parens.
    openTally '(' tally | tally >= 0 = tally + 1
    openTally ')' tally = tally - 1
    -- Non-parens has no effect
    openTally _ tally = tally

    sumParens :: Array Char -> State Int Unit
    sumParens = traverse_ \c -> modify_ $ openTally c

    finalTally :: Int
    finalTally = execState (sumParens $ toCharArray str) 0
  in
    finalTally == 0

--

type Level = Int
type Doc = (Reader Level) String

line :: String -> Doc
line str = do
  level <- ask
  pure $ (power "  " level) <> str

indent :: Doc -> Doc
indent = local $ (+) 1

cat :: Array Doc -> Doc
cat = sequence >=> joinWith "\n" >>> pure

render :: Doc -> String
render doc = runReader doc 0

--

sumArrayWriter :: Array Int -> Writer (Additive Int) Unit
sumArrayWriter = traverse_ \n -> do
  tell $ Additive n
  pure unit

--

collatz :: Int -> Tuple Int (Array Int)
collatz c = runWriter $ cltz 0 c
  where
    cltz :: Int -> Int -> Writer (Array Int) Int
    cltz i 1 = do
      tell [ 1 ]
      pure i
    cltz i n = do
      tell [ n ]
      if mod n 2 == 0
        then cltz (i + 1) (n / 2)
        else cltz (i + 1) ((3 * n) + 1)

--

safeDivide :: Int -> Int -> ExceptT String Identity Int
safeDivide _ 0 = throwError "Divide by zero!"
safeDivide a b = pure $ a / b

--

type Errors = Array String
type Log = Array String
type Parser = StateT String (WriterT Log (ExceptT Errors Identity))

string :: String -> Parser String
string prefix = do
  st <- get
  lift $ tell ["The state is " <> st]
  case stripPrefix (Pattern prefix) st of
    Just rest -> do
      put rest
      pure prefix
    _ -> do
      lift $ lift $ throwError ["Could not parse"]

--

type Level' = Int
type Doc' = (WriterT (Array String) (ReaderT Level' Identity)) Unit

line' :: String -> Doc'
line' s = do
  level <- lift $ ask
  tell [ (power "  " level) <> s ]
  pure unit

indent' :: Doc' -> Doc'
indent' = local $ (+) 1

render' :: Doc' -> String
render' doct = joinWith "\n" $ unwrap $ runReaderT (execWriterT doct) 0

asFollowedByBs ::  Parser String
asFollowedByBs = do
  as <- some $ string "a"
  bs <- some $ string "b"
  pure $ fold $ as <> bs

asOrBs :: Parser String
asOrBs = fold <$> some (string "a" <|> string "b")

-- Note, that this function should be defined in Game.purs to avoid creating a circular dependency.
cheat :: Game Unit
cheat = do
  GameState state <- get
  let newInventory = foldl S.union state.inventory state.items
  tell $ foldl (\acc x -> ("You now have the " <> show x) : acc) L.Nil $ S.unions state.items
  put $ GameState state { items = M.empty, inventory = newInventory }
