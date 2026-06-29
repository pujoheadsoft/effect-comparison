{-# LANGUAGE DeriveFunctor #-}

module StateFree
  ( Free(..)
  , StateF(..)
  , get
  , set
  , runState
  , example
  ) where

import Free

data StateF s next
  = Get (s -> next)
  | Set s next
  deriving (Functor)

get :: Free (StateF s) s
get = Op (Get Pure)

set :: s -> Free (StateF s) ()
set s = Op (Set s (Pure ()))

runState :: s -> Free (StateF s) a -> (a, s)
runState s (Pure a) = (a, s)
runState s (Op (Get k)) = runState s (k s)
runState _ (Op (Set s next)) = runState s next

example :: Free (StateF Int) (Int, Int)
example = do
  x <- get
  set (x + 1)
  y <- get
  pure (x, y)

example2 :: Free (StateF Int) (Int, Int)
example2 =
  Op (Get (\x ->
    Op (Set (x + 1)
      (Op (Get (\y ->
        Pure (x, y)))))))



