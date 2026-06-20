# haskell

Haskell 版は、State effect を自前の Free monad で明示的に表す。

理論上の State effect は、状態集合 `S` を固定して次の operation を持つ。

```text
get : () -> S
put : S -> ()
```

Haskell サンプルでは、この `S` を型パラメータ `s` として `StateF s` に反映している。

```haskell
data Free f a
  = Pure a
  | Op (f (Free f a))

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

## Run

```sh
stack run state-example
```

期待される出力:

```text
runState 0 example = ((0,1),1)
```

## Test

```sh
stack test
```

テストでは `hspec` と `QuickCheck` を使い、`Int` State として law を確認する。

## File Guide

- `src/StateFree.hs`: `Free`、`StateF s`、`get`、`put`、`modify`、`runState`、`example`
- `app/Main.hs`: 初期状態 `0` で `example` を実行
- `test/Spec.hs`: `Int` State としての State law tests
- `package.yaml` / `stack.yaml`: Stack + hpack のプロジェクト設定

## Law Tests

ここでの等式テストは、処理系が State law を自動的に保証していることを意味しない。

テストしているのは、今回定義した `runState` interpreter のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
