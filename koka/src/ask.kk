module ask

pub effect ask<r>
  fun ask() : r

pub fun run-ask(env : r, action : () -> <ask<r>|e> a) : e a
  with fun ask() env
  action()
