{-# LANGUAGE DeriveFunctor #-}

module AskFree
  ( AskF(..)
  ) where

newtype AskF r next
  = Ask (r -> next)
  deriving (Functor)
