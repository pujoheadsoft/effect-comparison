# Effect comparison

同じ `State` effect を複数の表現で実装し、比較するためのサンプル集。

- Eff: 言語機能としての algebraic effects / handlers
- Koka: 言語機能としての algebraic effects / handlers と effect rows
- Haskell: 同じ演算のシグネチャを Free monad と interpreter として明示的にエンコードしたもの

Haskell 版は、言語機能として algebraic effects を実装している例ではない。演算のシグネチャ、未処理の計算、interpreter の構造を露出させて比較するための Free monad encoding である。

## State Example

理論上の State effect は、状態集合 `S` を固定して定義される。

```text
get : () -> S
put : S -> ()
```

このリポジトリでは、Eff 版は現行 Eff 実装に合わせて `S = int` の具体例として実装している。一方、Koka 版と Haskell 版では、同じ構造を状態型 `s` でパラメータ化して実装している。

ただし、三言語の実行例と law tests では、比較しやすいように `S = int` / `Int` を用いる。

共通のサンプルプログラムは以下。

```text
x <- get
put (x + 1)
y <- get
return (x, y)
```

初期状態 `0` で実行すると、三つとも次の結果になる。

```text
返り値  : (0, 1)
最終状態: 1
全体    : ((0, 1), 1)
```

## Layout

```text
effect-comparison/
  README.md
  eff/
    README.md
    Makefile
    src/state.eff
    test/state_test.eff
  koka/
    README.md
    src/state.kk
    src/main.kk
    test/state-test.kk
  haskell/
    README.md
    package.yaml
    stack.yaml
    app/Main.hs
    src/StateFree.hs
    test/Spec.hs
```

## Commands

Eff:

```sh
cd eff
make run
make test
```

Koka:

```sh
cd koka
koka --include=src -e src/main.kk
koka --include=src -e test/state-test.kk
```

Haskell:

```sh
cd haskell
stack run state-example
stack test
```

## Correspondence

| 概念 | Eff | Koka | Haskell |
| --- | --- | --- | --- |
| 状態型 | `int` 固定 | `s` でパラメータ化、例では `int` | `s` でパラメータ化、例では `Int` |
| effect signature | `Get : int`, `Set : int -> unit` | `state<s>` with `get : () -> s`, `set : s -> ()` | `StateF s next = Get (s -> next) \| Put s next` |
| read operation | `perform Get` | `get()` | `get :: Free (StateF s) s` |
| write operation | `perform (Set n)` | `set(x)` | `put :: s -> Free (StateF s) ()` |
| handler / interpreter | `run_state : int -> ... -> (..., int)` | `run-state : s -> ... -> (..., s)` | `runState :: s -> Free (StateF s) a -> (a, s)` |
| unhandled computation | `Get` / `Set` を含む計算 | `state<s>` effect を持つ direct-style 計算 | `Free (StateF s) a` の構文木 |
| continuation | handler clause の `k` | `resume` | `Get (s -> next)` の関数 |

## Notes

Eff 5.1 では operation をトップレベルに宣言する。そのため Eff 版では `effect Get : int` と `effect Set : int -> unit` を別々に書いているが、ここでは同じ State signature に属する二つの operation として扱う。現行 Eff で確実に動くサンプルにするため、状態型は `int` に単相化している。

Koka 版は `effect state<s>` として状態型をパラメータ化している。`run-state` は、開いた effect row `<state<s>|e>` ではなく閉じた `state<s>` を受け取り、状態渡し関数 `s -> (a, s)` を組み立てる純粋な handler として書いている。

Haskell 版では、`StateF s next` として signature functor を状態型 `s` でパラメータ化している。`Free (StateF s) a` が未処理計算、`runState` が handler / interpreter に対応する。

## Law Tests

各プロジェクトでは、代表的な State equation をテストしている。二つのプログラムを同じ初期状態で実行し、返り値と最終状態が一致することを確認する。

```text
get >>= put = return ()
put s >> put t = put t
put s >> get = put s >> return s
get >>= \s -> get >>= \t -> k s t
  =
get >>= \s -> k s s
```

ここでの等式テストは、処理系が State law を自動的に保証していることを意味しない。

テストしているのは、今回定義した `runState` handler / interpreter のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。

## Checked Commands And Results

Eff:

```text
$ cd eff && make run
run_state 0 example = ((0, 1), 1)

$ cd eff && make test
ok - example
...
all state law tests passed
```

Koka:

```text
$ cd koka && koka --include=src -e src/main.kk
run-state(0, example) = ((0,1),1)

$ cd koka && koka --include=src -e test/state-test.kk
ok - example
...
all state law tests passed
```

Haskell:

```text
$ cd haskell && stack run state-example
runState 0 example = ((0,1),1)

$ cd haskell && stack test
6 examples, 0 failures
```

## Tool Versions Checked

```text
Eff 5.1(Unix)
Koka 3.2.2
Stack 3.9.1
Stack resolver lts-22.43 (GHC 9.6.6)
```

Eff は upstream の OPAM pin でインストールした。

```sh
opam pin add -k git eff https://github.com/matijapretnar/eff.git
```
