# Effect comparison

同じ `State` effect と、`State + Ask` の合成を複数の表現で実装し、比較するためのサンプル集。

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

共通の State サンプルプログラムは以下。

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

## State + Ask Example

`Ask` は読み取り専用の環境から値を得る effect として扱う。

```text
ask : () -> R
```

合成サンプルでは、`Ask` から増分 `delta` を読み、`State` から現在状態を読み、状態を `x + delta` に更新する。

```text
delta <- ask
x <- get
put (x + delta)
y <- get
return (x, y)
```

三言語とも、実行例では `R = int` / `Int`、`S = int` / `Int` として、環境 `3`、初期状態 `10` で実行する。

```text
返り値  : (10, 13)
最終状態: 13
全体    : ((10, 13), 13)
```

State の定義ファイルには Ask を入れず、Ask と State+Ask の合成は別ファイルに分けている。合成サンプルは、複数の operation を含む未処理計算を handler / interpreter で解釈する形を比較するためのもの。三つの実装が処理系レベルで同一の数学的対象を自動的に提供している、という主張ではない。

## Layout

```text
effect-comparison/
  README.md
  scripts/
    build-all.sh
    run-all.sh
    test-all.sh
  eff/
    README.md
    src/state.eff
    src/ask.eff
    src/state_ask.eff
    src/main.eff
    test/state_test.eff
    test/state_ask_test.eff
  koka/
    README.md
    src/state.kk
    src/ask.kk
    src/state-ask.kk
    src/main.kk
    test/state-test.kk
    test/state-ask-test.kk
  haskell/
    README.md
    package.yaml
    stack.yaml
    app/Main.hs
    src/Free.hs
    src/StateFree.hs
    src/AskFree.hs
    src/StateAskFree.hs
    test/Spec.hs
    test/StateSpec.hs
    test/StateAskSpec.hs
```

## Commands

All projects:

```sh
./scripts/build-all.sh
./scripts/run-all.sh
./scripts/test-all.sh
```

成功時はそれぞれ `OK: build all`、`OK: run all`、`OK: test all` を表示する。

Eff:

```sh
cd eff
./build.sh
./run.sh
./test.sh
```

Koka:

```sh
cd koka
./build.sh
./run.sh
./test.sh
```

Haskell:

```sh
cd haskell
stack build
stack run state-example
stack test
```

## Correspondence

| 概念 | Eff | Koka | Haskell |
| --- | --- | --- | --- |
| 状態型 | `int` 固定 | `s` でパラメータ化、例では `int` | `s` でパラメータ化、例では `Int` |
| State signature | `Get : int`, `Set : int -> unit` | `state<s>` with `fun get : () -> s`, `fun set : s -> ()` | `StateF s next = Get (s -> next) \| Put s next` |
| Ask signature | `Ask : int` | `ask<r>` with `fun ask : () -> r` | `AskF r next = Ask (r -> next)` |
| State read operation | `perform Get` | `get()` | `get :: Free (StateF s) s` |
| State write operation | `perform (Set n)` | `set(x)` | `put :: s -> Free (StateF s) ()` |
| Ask operation | `perform Ask` | `ask()` | `ask :: Free (StateAskF s r) r` |
| State handler / interpreter | `run_state : int -> ... -> (..., int)` | `run-state : s -> ... -> <div|e> (..., s)` | `runState :: s -> Free (StateF s) a -> (a, s)` |
| State + Ask handler / interpreter | `run_state_ask : int -> int -> ... -> (..., int)` | `run-state-ask : r -> s -> ... -> <div|e> (..., s)` | `runStateAsk :: r -> s -> Free (StateAskF s r) a -> (a, s)` |
| State definition file | `eff/src/state.eff` | `koka/src/state.kk` | `haskell/src/StateFree.hs` |
| Ask definition file | `eff/src/ask.eff` | `koka/src/ask.kk` | `haskell/src/AskFree.hs` |
| Composition file | `eff/src/state_ask.eff` | `koka/src/state-ask.kk` | `haskell/src/StateAskFree.hs` |
| unhandled computation | `Get` / `Set` / `Ask` を含む計算 | `<state<s>,ask<r>>` effect を持つ direct-style 計算 | `Free (StateAskF s r) a` の構文木 |
| continuation | handler clause の `k` | tail-resumptive な `fun` operation | `Get (s -> next)` / `Ask (r -> next)` の関数 |

## Notes

Eff 5.1 では operation をトップレベルに宣言する。State については、現行 Eff で確実に動くサンプルにするため、状態型を `int` に単相化している。`state.eff` は `Get` / `Set` と `run_state` だけを持ち、`ask.eff` が `Ask`、`state_ask.eff` が合成を担当する。Eff の実行では `-l` で必要な定義ファイルをロードする。

Koka 版は `effect state<s>` として状態型をパラメータ化し、`effect ask<r>` として環境型もパラメータ化している。`get` / `set` / `ask` は tail-resumptive な operation として `fun` で宣言している。`run-state` は公式ドキュメントの State handler と同じ形で、ローカル状態を `var` で保持し、`with return` と `with handler` で解釈する。合成サンプルでは `state-ask.kk` で `with run-state(init)` と `with run-ask(env)` を重ねている。

Haskell 版では、`StateF s next` と `AskF r next` を別々の signature functor として定義している。State 単独では `Free (StateF s) a`、合成サンプルでは sum functor `Sum (StateF s) (AskF r)` による `Free (StateAskF s r) a` を使う。

Haskell 版の `StateAskF s r = Sum (StateF s) (AskF r)` は、State operation と Ask operation を同じ Free の木に入れるための最小限の表現である。これは本格的な open union や extensible effects の実装ではない。operation signature の和と interpreter の対応が見えるようにした、State+Ask 専用の encoding である。

Eff / Koka の State+Ask 例では、Ask は読み取り専用の環境であり、State と干渉しない。そのため、このサンプルでは handler を重ねることで、環境値 `3` と初期状態 `10` から `((10,13),13)` が得られる。handler の順序が一般にいつでも同じ意味になる、という主張ではない。

## Law Tests

各プロジェクトでは、代表的な State equation をテストしている。二つのプログラムを同じ初期状態で実行し、返り値と最終状態が一致することを確認する。テストの実行値は三言語とも `int` / `Int` でそろえている。

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
$ cd eff && eff -l src/state.eff -l src/ask.eff -l src/state_ask.eff src/main.eff
run_state 0 example = ((0, 1), 1)
run_state_ask 3 10 state_ask_example = ((10, 13), 13)

$ cd eff && eff -l src/state.eff test/state_test.eff
ok - example
...
all state law tests passed

$ cd eff && eff -l src/state.eff -l src/ask.eff -l src/state_ask.eff test/state_ask_test.eff
ok - state + ask example
all state + ask tests passed
```

Koka:

```text
$ cd koka && koka --include=src -e src/main.kk
run-state(0, example) = ((0,1),1)
run-state-ask(3, 10, state-ask-example) = ((10,13),13)

$ cd koka && koka --include=src -e test/state-test.kk
ok - example
...
all state law tests passed

$ cd koka && koka --include=src -e test/state-ask-test.kk
ok - state + ask example
all state + ask tests passed
```

Haskell:

```text
$ cd haskell && stack run state-example
runState 0 example = ((0,1),1)
runStateAsk 3 10 stateAskExample = ((10,13),13)

$ cd haskell && stack test
7 examples, 0 failures
```

## Tool Versions Checked

```text
Eff 5.1(Unix)
Koka 3.2.2
Stack 3.9.1
Stack resolver lts-22.43 with compiler ghc-9.6.7
```

Eff は upstream の OPAM pin でインストールした。

```sh
opam pin add -k git eff https://github.com/matijapretnar/eff.git
```
