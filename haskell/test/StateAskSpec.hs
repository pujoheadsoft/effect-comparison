module StateAskSpec
  ( spec
  ) where

import Test.Hspec

import StateAskFree

spec :: Spec
spec =
  describe "State + Ask composition" $
    it "reads a delta from Ask and updates State" $
      runStateAsk 3 10 stateAskExample `shouldBe` (((10, 13) :: (Int, Int)), 13)
