module state

pub effect state<s>
  fun get() : s
  fun set(x : s) : ()

pub fun run-state(init : s, action : () -> <state<s>, div|e> a) : <div|e> (a, s)
  var current := init
  with return(x) (x, current)
  with handler
    fun get() current
    fun set(x) current := x
  action()

pub fun example() : state<int> (int, int)
  val x = get()
  set(x + 1)
  val y = get()
  (x,y)


