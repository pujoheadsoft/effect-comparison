# eff

Eff 版は、現行 Eff 5.1 の構文に合わせて State effect を `int` 状態の具体例として実装している。Ask と State+Ask の合成は State 本体とは別ファイルに分けている。

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

`state_handler init` は `Get` と `Set` を、初期状態 `init` からの状態変換として解釈する handler である。handler clause の continuation `k` を使い、状態を引数に取る関数へ変換してから `finally` で初期状態を渡す。`run_state init action` は `with state_handler init handle action ()` として、この handler を実行する。

## State + Ask

`Ask` は `int` の読み取り専用環境として `src/ask.eff` に定義している。

```eff
effect Ask : int
```

合成サンプルは `src/state_ask.eff` に置いている。

```text
delta <- ask
x <- get
put (x + delta)
y <- get
return (x, y)
```

`run_state_ask env init action` は `with ask_handler env handle` と `with state_handler init handle` を重ねて実装している。環境 `3`、初期状態 `10` で `state_ask_example` を実行すると `((10, 13), 13)` になる。

この例では Ask は読み取り専用の環境であり、State と干渉しない。そのため、このサンプルでは handler を重ねても、環境値 `3` と初期状態 `10` から `((10,13),13)` が得られる。handler の順序が一般にいつでも同じ意味になる、という主張ではない。

## Install Eff

公式 README は OPAM pin を推奨している。

```sh
opam pin add -k git eff https://github.com/matijapretnar/eff.git
```

この環境では `eff 5.1(Unix)` で確認した。

## Run

```sh
./run.sh
```

実行内容は次の直接コマンドと同じ。

```sh
eff -l src/state.eff -l src/ask.eff -l src/state_ask.eff src/main.eff
```

期待される出力:

```text
run_state 0 example = ((0, 1), 1)
run_state_ask 3 10 state_ask_example = ((10, 13), 13)
```

## Test

```sh
./test.sh
```

実行内容は次の直接コマンドと同じ。

```sh
eff -l src/state.eff test/state_test.eff
eff -l src/state.eff -l src/ask.eff -l src/state_ask.eff test/state_ask_test.eff
```

成功時は State law tests と State + Ask example の結果に加えて `OK: Eff tests` を表示する。

## File Guide

- `src/state.eff`: `Get` / `Set`、`state_handler`、`run_state`、`get`、`put`、`example`
- `src/ask.eff`: `Ask`、`ask`、`ask_handler`、`run_ask`
- `src/state_ask.eff`: `run_state_ask`、`state_ask_example`
- `src/main.eff`: State example と State + Ask example を実行
- `test/state_test.eff`: `int` State としての State law tests
- `test/state_ask_test.eff`: State + Ask の実行例
- `build.sh` / `run.sh` / `test.sh`: `eff` CLI を呼ぶ薄い script

## Law Tests

ここでの等式テストは、処理系が State law を自動的に保証していることを意味しない。

テストしているのは、今回定義した `run_state` handler のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
