# koka

Koka 版は、direct style の algebraic effect と handler で State effect を定義する。

理論上の State effect は、状態集合 `S` を固定して次の operation を持つ。

```text
get : () -> S
put : S -> ()
```

Koka サンプルでは、この `S` を型パラメータ `s` としてコードに反映している。

```koka
effect state<s>
  ctl get() : s
  ctl set(x : s) : ()
```

`run-state` も状態型 `s` について一般的に定義している。

```koka
pub fun run-state(init : s, action : () -> state<s> a) : (a,s)
```

`run-state` はローカル可変変数ではなく、handler が状態渡し関数 `s -> (a,s)` を組み立てる形で書いている。このため、型シグネチャに `div` effect が漏れない。また、State 単独の等式理論として読めるように、他の effect row を合成できる `<state<s>|e>` ではなく、閉じた `state<s>` を受け取る型にしている。

共通サンプル `example` と tests では、比較しやすいように `s = int` を使う。

## Version

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

成功時は各 law の `ok - ...` と最後に `all state law tests passed` を表示する。

## File Guide

- `src/state.kk`: `effect state<s>`、`get`、`set`、`modify`、`run-state`、`example`
- `src/main.kk`: 初期状態 `0` で `example` を実行
- `test/state-test.kk`: `int` State としての State law tests

## Law Tests

ここでの等式テストは、処理系が State law を自動的に保証していることを意味しない。

テストしているのは、今回定義した `run-state` handler のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値である。
