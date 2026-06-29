module StateAskFree
  ( StateAskF
  , ask
  , getStateAsk
  , setStateAsk
  , stateAskExample
  , runStateAsk
  ) where

import Data.Functor.Sum (Sum(..))

import AskFree
import Free
import StateFree

type StateAskF s r = Sum (StateF s) (AskF r)

ask :: Free (StateAskF s r) r
ask = Op (InR (Ask Pure))

getStateAsk :: Free (StateAskF s r) s
getStateAsk = Op (InL (Get Pure))

setStateAsk :: s -> Free (StateAskF s r) ()
setStateAsk s = Op (InL (Set s (Pure ())))

stateAskExample :: Free (StateAskF Int Int) (Int, Int)
stateAskExample = do
  delta <- ask
  x <- getStateAsk
  setStateAsk (x + delta)
  y <- getStateAsk
  pure (x, y)

runStateAsk :: r -> s -> Free (StateAskF s r) a -> (a, s)
runStateAsk _ s (Pure a) = (a, s)
runStateAsk env s (Op (InL (Get k))) = runStateAsk env s (k s)
runStateAsk env _ (Op (InL (Set s next))) = runStateAsk env s next
runStateAsk env s (Op (InR (Ask k))) = runStateAsk env s (k env)
