{-# LANGUAGE ScopedTypeVariables #-}

module StateSpec
  ( spec
  ) where

import Test.Hspec hiding (example)
import Test.QuickCheck

import Free
import StateFree

spec :: Spec
spec = do
  describe "example" $
    it "returns the first and second state, plus the final state" $
      runState 0 example `shouldBe` (((0, 1) :: (Int, Int)), 1)

  describe "State laws under runState" $ do
    it "Law 1: get >>= set = return ()" $
      property $ \(initState :: Int) ->
        runState initState (do s <- get; set s) ===
        runState initState (pure () :: Free (StateF Int) ())

    it "Law 2: set s >> set t = set t" $
      property $ \(initState :: Int) (s :: Int) (t :: Int) (value :: Int) ->
        runState initState (do set s; set t; pure value) ===
        runState initState (do set t; pure value)

    it "Law 3: set s >> get = set s >> return s" $
      property $ \(initState :: Int) (s :: Int) ->
        runState initState (do set s; x <- get; pure x) ===
        runState initState (do set s; pure s)

    it "Law 4a: two gets read the same value for pure k" $
      property $ \(initState :: Int) ->
        runState initState (do s <- get; t <- get; pure (s, t)) ===
        runState initState (do s <- get; pure (s, s))

    it "Law 4b: two gets read the same value for state-changing k" $
      property $ \(initState :: Int) ->
        runState initState (do s <- get; t <- get; set (s + t); pure (s, t)) ===
        runState initState (do s <- get; set (s + s); pure (s, s))
