# eff

Eff 版は、現行 Eff 5.1 の構文に合わせて State effect を `int` 状態の具体例として実装している。

理論上の State effect は状態集合 `S` を固定して、概念的には次の operation を持つ。

```text
get : () -> S
put : S -> ()
```

この Eff サンプルでは `S = int` として、次の operation を使う。

```eff
effect Get : int
effect Set : int -> unit
```

Eff 5.1 では operation をトップレベルに宣言するため、`Get` と `Set` はコード上は別々の宣言として現れる。ここでは、これらを同じ State signature に属する二つの operation として扱う。

`run_state init action` は `Get` と `Set` を、初期状態 `init` からの状態変換として解釈する handler である。handler clause の continuation `k` を使い、状態を引数に取る関数へ変換してから `finally` で初期状態を渡す。

## Install Eff

公式 README は OPAM pin を推奨している。

```sh
opam pin add -k git eff https://github.com/matijapretnar/eff.git
```

この環境では `eff 5.1(Unix)` で確認した。

## Run

```sh
make run
```

期待される出力:

```text
run_state 0 example = ((0, 1), 1)
```

## Test

```sh
make test
```

成功時は各 law の `ok - ...` と最後に `all state law tests passed` を表示する。

## File Guide

- `src/state.eff`: `Get` / `Set`、`run_state`、`get`、`put`、`modify`、`example`
- `test/state_test.eff`: `int` State としての State law tests
- `Makefile`: `make run` / `make test`

## Law Tests

ここでの等式テストは、処理系が State law を自動的に保証していることを意味しない。

テストしているのは、今回定義した `run_state` handler のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
