module state-ask

import state
import ask

pub fun run-state-ask(env : r, init : s, action : () -> <state<s>,ask<r>,div|e> a) : <div|e> (a,s)
  with run-state(init)
  with run-ask(env)
  action()

pub fun state-ask-example() : <state<int>,ask<int>> (int,int)
  val delta : int = ask()
  val x : int = get()
  set(x + delta)
  val y : int = get()
  (x,y)
