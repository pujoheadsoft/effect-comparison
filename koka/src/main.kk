module main

import state

pub fun main()
  val result = run-state(0, example)
  println("run-state(0, example) = " ++ result.show)
