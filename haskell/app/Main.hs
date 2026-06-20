module Main where

import StateFree

main :: IO ()
main =
  putStrLn ("runState 0 example = " ++ show (runState 0 example))
