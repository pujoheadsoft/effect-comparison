module state-test

import state

// 1. get した値をそのまま set し直すなら、何もしないのと同じ。
fun law1(init : int)
  val left = run-state(init, fn(){ val s = get(); set(s) })
  val right = run-state(init, fn(){ () })
  assert-eq("law1 init=" ++ init.show, left, right)

// 2. set を二回続けると、最後の set だけが残る。
fun law2(init : int, s : int, t : int, value : int)
  val left = run-state(init, fn(){ set(s); set(t); value })
  val right = run-state(init, fn(){ set(t); value })
  assert-eq("law2 init=" ++ init.show ++ " s=" ++ s.show ++ " t=" ++ t.show, left, right)

// 3. set の直後に get すると、set した値が得られる。
fun law3(init : int, s : int)
  val left = run-state(init, fn(){ set(s); val x = get(); x })
  val right = run-state(init, fn(){ set(s); s })
  assert-eq("law3 init=" ++ init.show ++ " s=" ++ s.show, left, right)

// 4. 状態を変えずに get を二回行うと、同じ値が得られる。
fun law4-pure(init : int)
  val left = run-state(init, fn(){ val s = get(); val t = get(); (s,t) })
  val right = run-state(init, fn(){ val s = get(); (s,s) })
  assert-eq("law4 pure init=" ++ init.show, left, right)

// 5. 4 の具体例として、2回 get した値を使って set する場合。
fun law4-set(init : int)
  val left = run-state(init, fn(){ val s : int = get(); val t : int = get(); set(s + t); (s,t) })
  val right = run-state(init, fn(){ val s : int = get(); set(s + s); (s,s) })
  assert-eq("law4 set init=" ++ init.show, left, right)

fun assert-eq(name : string, actual : a, expected : a, ?show : a -> string, ?(==) : (a,a) -> bool) : <console,exn> ()
  if actual == expected then
    println("ok - " ++ name)
  else
    throw("FAILED - " ++ name ++ ": actual = " ++ actual.show ++ ", expected = " ++ expected.show)

pub fun main()
  assert-eq("example", run-state(0, example), ((0,1),1))

  law1(0)
  law1(1)
  law1(-5)

  law2(0, 1, 2, 99)
  law2(10, -3, 7, 42)
  law2(-8, 5, 5, 0)

  law3(0, 12)
  law3(10, -4)
  law3(-1, 0)

  law4-pure(0)
  law4-pure(17)
  law4-pure(-3)

  law4-set(0)
  law4-set(17)
  law4-set(-3)

  println("all state law tests passed")
