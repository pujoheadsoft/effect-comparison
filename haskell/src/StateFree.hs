{-# LANGUAGE DeriveFunctor #-}

module StateFree
  ( Free(..)
  , StateF(..)
  , get
  , put
  , modify
  , runState
  , example
  ) where

import Free

data StateF s next
  = Get (s -> next)
  | Put s next
  deriving (Functor)

get :: Free (StateF s) s
get = Op (Get Pure)

put :: s -> Free (StateF s) ()
put s = Op (Put s (Pure ()))

modify :: (s -> s) -> Free (StateF s) ()
modify f = do
  s <- get
  put (f s)

runState :: s -> Free (StateF s) a -> (a, s)
runState s (Pure a) = (a, s)
runState s (Op (Get k)) = runState s (k s)
runState _ (Op (Put s next)) = runState s next

example :: Free (StateF Int) (Int, Int)
example = do
  x <- get
  put (x + 1)
  y <- get
  pure (x, y)
