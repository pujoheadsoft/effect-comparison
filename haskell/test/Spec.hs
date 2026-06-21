module Main where

import Test.Hspec

import qualified StateAskSpec
import qualified StateSpec

main :: IO ()
main = hspec $ do
  StateSpec.spec
  StateAskSpec.spec
