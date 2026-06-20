# haskell

Haskell 版は State effect を自前の Free monad で明示的に表します。

```haskell
data Free f a
  = Pure a
  | Op (f (Free f a))

data StateF s next
  = Get (s -> next)
  | Put s next
  deriving (Functor)
```

`StateF` が effect signature、`Free (StateF s) a` がまだ handler に渡していない計算、`runState` が handler / interpreter です。

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

テストでは `hspec` と `QuickCheck` を使い、次の law を `runState` 後の返り値と最終状態の一致として確認します。

```text
get >>= put = return ()
put s >> put t = put t
put s >> get = put s >> return s
get >>= \s -> get >>= \t -> k s t = get >>= \s -> k s s
```

## File Guide

- `src/StateFree.hs`: `Free`、`StateF`、`get`、`put`、`modify`、`runState`、`example`
- `app/Main.hs`: 初期状態 `0` で `example` を実行
- `test/Spec.hs`: State law のテスト
- `package.yaml` / `stack.yaml`: Stack + hpack のプロジェクト設定

## Correspondence

| 概念 | Eff | Koka | Haskell |
| --- | --- | --- | --- |
| effect signature | `effect Get`, `effect Set` | `effect state<s>` with `ctl get` / `ctl set` | `data StateF s next = Get (s -> next) | Put s next` |
| read operation | `perform Get` | `get()` | `get` |
| write operation | `perform (Set s)` | `set(s)` | `put` |
| handler | `handler ... finally ...` | `run-state(init, action)` | `runState` |
| unhandled comp. | operation を含む Eff 計算 | effect row に `state<s>` を持つ direct-style 計算 | `Free (StateF s) a` |
| continuation | handler clause の `k` | `ctl` clause の `resume` | `Get (s -> next)` の関数 |

ここでの等式テストは、State effect の law を処理系が自動的に保証していることを意味しない。
テストしているのは、今回定義した runState handler / interpreter のもとで、
二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
