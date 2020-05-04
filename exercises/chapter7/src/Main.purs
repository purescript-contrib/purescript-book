module Main where

import Prelude
import Effect (Effect)
import Effect.Console (logShow)

main :: Effect Unit
main = do
  -- t1, t2 and t3 will be identical, but the order of effects (printing values at nodes) will be different
  t1 <- traverseInOrder logShow sampleTree -- 1 2 3
  t2 <- traversePreOrder logShow sampleTree -- 2 1 3
  t3 <- traversePostOrder logShow sampleTree -- 1 3 2  
  pure unit

data Tree a
  = Leaf
  | Branch (Tree a) a (Tree a)

sampleTree :: Tree Int
sampleTree = Branch (Branch Leaf 1 Leaf) 2 (Branch Leaf 3 Leaf)

traverseInOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
traverseInOrder _ Leaf = pure Leaf

-- first evaluate left branch, then node, then right branch
traverseInOrder f (Branch l x r) = Branch <$> traverseInOrder f l <*> f x <*> traverseInOrder f r

traversePreOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
traversePreOrder _ Leaf = pure Leaf

-- first evaluate node, then left branch and then right branch. Notice the lambda function shuffles the arguments where they need to be
traversePreOrder f (Branch l x r) = (\x' l' r' -> Branch l' x' r') <$> f x <*> traversePreOrder f l <*> traversePreOrder f r

traversePostOrder :: forall f a b. Applicative f => (a -> f b) -> Tree a -> f (Tree b)
traversePostOrder _ Leaf = pure Leaf

traversePostOrder f (Branch l x r) = (\l' r' x' -> Branch l' x' r') <$> traversePostOrder f l <*> traversePostOrder f r <*> f x
