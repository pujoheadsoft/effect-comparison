module state-ask-test

import state-ask
import ask
import state

fun assert-eq(name : string, actual : a, expected : a, ?show : a -> string, ?(==) : (a,a) -> bool) : <console,exn> ()
  if actual == expected then
    println("ok - " ++ name)
  else
    throw("FAILED - " ++ name ++ ": actual = " ++ actual.show ++ ", expected = " ++ expected.show)

pub fun main()
  assert-eq("state + ask example", run-state-ask(3, 10, state-ask-example), ((10,13),13))
  println("all state + ask tests passed")
