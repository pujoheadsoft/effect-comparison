# haskell

Haskell 版は、State effect を自前の Free monad で明示的に表す。Ask と State+Ask の合成は State 本体とは別モジュールに分けている。

理論上の State effect は、状態集合 `S` を固定して次の operation を持つ。

```text
get : () -> S
put : S -> ()
```

Haskell サンプルでは、この `S` を型パラメータ `s` として `StateF s` に反映している。

```haskell
data StateF s next
  = Get (s -> next)
  | Put s next
  deriving (Functor)
```

`StateF s` が effect signature、`Free (StateF s) a` が未処理計算、`runState` が handler / interpreter に対応する。

```haskell
get :: Free (StateF s) s
put :: s -> Free (StateF s) ()
modify :: (s -> s) -> Free (StateF s) ()
runState :: s -> Free (StateF s) a -> (a, s)
```

共通サンプル `example` と tests では、比較しやすいように `s = Int` を使う。

```haskell
example :: Free (StateF Int) (Int, Int)
```

## State + Ask

Ask は `AskFree` で環境型 `r` にパラメータ化した signature functor として定義している。

```haskell
newtype AskF r next
  = Ask (r -> next)
  deriving (Functor)
```

State と Ask の合成は `StateAskFree` で定義し、sum functor を使う。

```haskell
type StateAskF s r = Sum (StateF s) (AskF r)
```

合成サンプル `stateAskExample` は `Free (StateAskF Int Int) (Int, Int)` の未処理計算である。`runStateAsk 3 10 stateAskExample` は `((10,13),13)` を返す。

`StateAskF s r = Sum (StateF s) (AskF r)` は、State operation と Ask operation を同じ Free の木に入れるための最小限の表現である。これは本格的な open union や extensible effects の実装ではない。operation signature の和と interpreter の対応が見えるようにした、State+Ask 専用の encoding である。

## Build

```sh
stack build
```

## Run

```sh
stack run state-example
```

期待される出力:

```text
runState 0 example = ((0,1),1)
runStateAsk 3 10 stateAskExample = ((10,13),13)
```

## Test

```sh
stack test
```

テストでは `hspec` と `QuickCheck` を使い、`Int` State として law を確認する。State + Ask の実行例も `Int` で確認する。成功時は `7 examples, 0 failures` を表示する。

## File Guide

- `src/Free.hs`: Free monad の共通定義
- `src/StateFree.hs`: `StateF s`、`get`、`put`、`modify`、`runState`、`example`
- `src/AskFree.hs`: `AskF r`
- `src/StateAskFree.hs`: `StateAskF s r`、`ask`、`getStateAsk`、`putStateAsk`、`runStateAsk`、`stateAskExample`
- `app/Main.hs`: 初期状態 `0` で `example` を、環境 `3` と初期状態 `10` で `stateAskExample` を実行
- `test/StateSpec.hs`: `Int` State としての State law tests
- `test/StateAskSpec.hs`: State + Ask の実行例
- `package.yaml` / `stack.yaml`: Stack + hpack のプロジェクト設定

## Law Tests

ここでの等式テストは、処理系が State law を自動的に保証していることを意味しない。

テストしているのは、今回定義した `runState` interpreter のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
