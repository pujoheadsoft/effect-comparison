# koka

Koka 版は、direct style の algebraic effect と handler で State effect を定義する。Ask と State+Ask の合成は State 本体とは別モジュールに分けている。

理論上の State effect は、状態集合 `S` を固定して次の operation を持つ。

```text
get : () -> S
put : S -> ()
```

Koka サンプルでは、この `S` を型パラメータ `s` としてコードに反映している。

```koka
effect state<s>
  fun get() : s
  fun set(x : s) : ()
```

`run-state` も状態型 `s` について一般的に定義している。

```koka
pub fun run-state(init : s, action : () -> <state<s>,div|e> a) : <div|e> (a,s)
```

`run-state` は Koka 公式ドキュメントの State handler と同じ流れで、ローカル状態を `var` で保持し、`with return` と `with handler` で `get` / `set` を解釈する。このため型には `div` が現れるが、外から見る結果は返り値と最終状態のペア `(a,s)` である。

共通サンプル `example` と tests では、比較しやすいように `s = int` を使う。

## State + Ask

Ask は `src/ask.kk` で環境型 `r` にパラメータ化している。

```koka
effect ask<r>
  fun ask() : r
```

合成サンプルは `src/state-ask.kk` に置いている。`state-ask-example` は、`<state<int>,ask<int>>` を持つ direct-style 計算である。

```text
delta <- ask
x <- get
set (x + delta)
y <- get
return (x, y)
```

`run-state-ask` は `with run-state(init)` と `with run-ask(env)` を重ねて、Koka の handler 合成として書いている。

```koka
pub fun run-state-ask(env : r, init : s, action : () -> <state<s>,ask<r>,div|e> a) : <div|e> (a,s)
```

環境 `3`、初期状態 `10` で `state-ask-example` を実行すると `((10,13),13)` になる。

## Version

```text
Koka 3.2.2
```

## Run

```sh
./run.sh
```

実行内容は基本的に次の直接コマンドと同じ。

```sh
koka --include=src -e src/main.kk
```

期待される出力:

```text
run-state(0, example) = ((0,1),1)
run-state-ask(3, 10, state-ask-example) = ((10,13),13)
```

## Test

```sh
./test.sh
```

実行内容は基本的に次の直接コマンドと同じ。

```sh
koka --include=src -e test/state-test.kk
koka --include=src -e test/state-ask-test.kk
```

成功時は State law tests と State + Ask example の結果に加えて `OK: Koka tests` を表示する。

## File Guide

- `src/state.kk`: `effect state<s>`、`get`、`set`、`modify`、`run-state`、`example`
- `src/ask.kk`: `effect ask<r>`、`ask`、`run-ask`
- `src/state-ask.kk`: `run-state-ask`、`state-ask-example`
- `src/main.kk`: 初期状態 `0` で `example` を、環境 `3` と初期状態 `10` で `state-ask-example` を実行
- `test/state-test.kk`: `int` State としての State law tests
- `test/state-ask-test.kk`: State + Ask の実行例
- `build.sh` / `run.sh` / `test.sh`: `koka` CLI を呼ぶ薄い script
- `koka-flags.sh`: ローカルの Koka share directory を補正する補助 script

## Law Tests

ここでの等式テストは、処理系が State law を自動的に保証していることを意味しない。

テストしているのは、今回定義した `run-state` handler のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
