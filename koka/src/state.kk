module state

pub effect state<s>
  ctl get() : s
  ctl set(x : s) : ()

pub fun modify(f : s -> s) : state<s> ()
  val x = get()
  set(f(x))

pub fun run-state(init : s, action : () -> state<s> a) : (a,s)
  with return(f) f(init)
  with handler
    ctl get() (fn(s) resume(s)(s))
    ctl set(x) (fn(_) resume(())(x))
  val x = action()
  fn(s) (x,s)

pub fun example() : state<int> (int,int)
  val x = get()
  set(x + 1)
  val y = get()
  (x,y)
