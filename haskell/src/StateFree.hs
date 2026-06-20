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

data Free f a
  = Pure a
  | Op (f (Free f a))

instance Functor f => Functor (Free f) where
  fmap f (Pure a) = Pure (f a)
  fmap f (Op op) = Op (fmap (fmap f) op)

instance Functor f => Applicative (Free f) where
  pure = Pure
  Pure f <*> x = fmap f x
  Op op <*> x = Op (fmap (<*> x) op)

instance Functor f => Monad (Free f) where
  Pure a >>= k = k a
  Op op >>= k = Op (fmap (>>= k) op)

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
