module Main where

import StateAskFree
import StateFree

main :: IO ()
main = do
  putStrLn $ "runState 0 example = " ++ show (runState 0 example)
  putStrLn $ "runStateAsk 3 10 stateAskExample = " ++ show (runStateAsk 3 10 stateAskExample)
