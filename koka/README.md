# koka

Koka 版は direct style の algebraic effect と handler で State effect を定義します。

```koka
effect state<s>
  ctl get() : s
  ctl set(x : s) : ()
```

`example` は普通の逐次プログラムのように `get()` と `set(...)` を呼びますが、型には未処理の `state<int>` effect が現れます。`run-state(init, action)` が handler で、返り値と最終状態の組 `(result, finalState)` を返します。

`run-state` はローカル可変変数ではなく、handler が状態渡し関数 `s -> (a,s)` を組み立てる形です。

```koka
pub fun run-state(init : s, action : () -> state<s> a) : (a,s)
```

このため、型シグネチャに `div` effect が漏れません。
また、State 単独の等式理論として読めるように、他の effect row を合成できる `<state<s>|e>` ではなく、閉じた `state<s>` を受け取る型にしています。

## Version

この環境では次を確認しました。

```text
Koka 3.2.2
```

## Run

```sh
koka --include=src -e src/main.kk
```

期待される出力:

```text
run-state(0, example) = ((0,1),1)
```

## Test

```sh
koka --include=src -e test/state-test.kk
```

テストフレームワークの代わりに `assert-eq` を定義し、失敗時は `throw(...)` で止めます。成功時は各 law の `ok - ...` と最後に `all state law tests passed` を表示します。

## File Guide

- `src/state.kk`: `effect state<s>`、`get`、`set`、`modify`、`run-state`、`example`
- `src/main.kk`: 初期状態 `0` で `example` を実行
- `test/state-test.kk`: State law のテスト

## Correspondence

| 概念 | Eff | Koka | Haskell |
| --- | --- | --- | --- |
| effect signature | `effect Get`, `effect Set` | `effect state<s>` with `ctl get` / `ctl set` | `data StateF s next = ...` |
| read operation | `perform Get` | `get()` | `get` |
| write operation | `perform (Set s)` | `set(s)` | `put` |
| handler | `handler ... finally ...` | `run-state(init, action)` | `runState` |
| unhandled comp. | operation を含む Eff 計算 | effect row に `state<s>` を持つ計算 | `Free (StateF s) a` |
| continuation | handler clause の `k` | `ctl` clause の `resume` | `Get (s -> next)` |

ここでの等式テストは、State effect の law を処理系が自動的に保証していることを意味しない。
テストしているのは、今回定義した runState handler / interpreter のもとで、
二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
