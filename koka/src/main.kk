module main

import state
import ask
import state-ask

pub fun main()
  val state-result = run-state(0, example)
  println("run-state(0, example) = " ++ state-result.show)

  val state-ask-result = run-state-ask(3, 10, state-ask-example)
  println("run-state-ask(3, 10, state-ask-example) = " ++ state-ask-result.show)
