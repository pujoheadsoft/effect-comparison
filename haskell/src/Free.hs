{-# LANGUAGE InstanceSigs #-}
module Free
  ( Free(..)
  ) where

data Free f a
  = Pure a
  | Op (f (Free f a))

instance Functor f => Functor (Free f) where
  fmap f (Pure a) = Pure (f a)
  fmap f (Op op) = Op (fmap (fmap f) op)

instance Functor f => Applicative (Free f) where
  pure :: Functor f => a -> Free f a
  pure = Pure
  Pure f <*> x = fmap f x
  Op op <*> x = Op (fmap (<*> x) op)

instance Functor f => Monad (Free f) where
  Pure a >>= k = k a
  Op op >>= k = Op (fmap (>>= k) op)
