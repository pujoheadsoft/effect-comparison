# eff

Eff 版は、State effect を `Get` / `Set` operation として定義します。Eff 5.1 の公式サンプルではトップレベル `effect Get : ...` の形が使われているため、このプロジェクトもその形に合わせています。また、現行構文で比較サンプルを確実に動かすため、状態型は `int` に単相化しています。

```eff
effect Get : int
effect Set : int -> unit
```

`run_state init action` は `Get` と `Set` を初期状態 `init` からの状態変換として解釈します。handler の各 clause は、未処理計算の continuation `k` を受け取り、状態を引数に取る関数へ変換します。

## Install Eff

公式 README は OPAM pin を推奨しています。

```sh
opam pin add -k git eff https://github.com/matijapretnar/eff.git
```

手動ビルドする場合:

```sh
git clone https://github.com/matijapretnar/eff.git
cd eff
make
```

この作業環境では公式手順で `eff 5.1(Unix)` をインストールして確認しました。

## Run

```sh
make run
```

これは次を実行します。

```sh
eff src/state.eff
```

期待される出力:

```text
run_state 0 example = ((0, 1), 1)
```

## Test

```sh
make test
```

これは次を実行します。

```sh
eff test/state_test.eff
```

成功時は各 law の `ok - ...` と最後に `all state law tests passed` を表示します。

## File Guide

- `src/state.eff`: effect signature、`run_state`、`get`、`put`、`modify`、`example`
- `test/state_test.eff`: State law のテスト
- `Makefile`: `make run` / `make test`

## Correspondence

| 概念 | Eff | Koka | Haskell |
| --- | --- | --- | --- |
| effect signature | `effect Get`, `effect Set` | `effect state<s>` with `ctl get` / `ctl set` | `data StateF s next = ...` |
| read operation | `perform Get` | `get()` | `get` |
| write operation | `perform (Set s)` | `set(s)` | `put` |
| handler | `run_state` の `handler` | `run-state(init, action)` | `runState` |
| unhandled comp. | `action ()` | effect row に `state<s>` を持つ計算 | `Free (StateF s) a` |
| continuation | handler clause の `k` | `ctl` clause の `resume` | `Get (s -> next)` |

ここでの等式テストは、State effect の law を処理系が自動的に保証していることを意味しない。
テストしているのは、今回定義した runState handler / interpreter のもとで、
二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
