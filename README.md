# Effect comparison

同じエフェクトを複数の表現で実装し、比較するためのサンプル集。

- Eff: 言語機能としての algebraic effects / handlers
- Koka: 言語機能としての algebraic effects / handlers と effect rows
- Haskell: 同じ演算のシグネチャを Free monad と interpreter として明示的にエンコードしたもの

Haskell 版は上記の通り、言語機能として algebraic effects を実装している例ではない。
演算のシグネチャ、未処理の計算、interpreter の構造を露出させて比較するためのもの。
なのであえて Free monad も自前実装している。

## State Example
比較する State operation は次の二つ。

```text
get : () -> s
put : s -> ()
```

共通のサンプルプログラムは以下。

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

## Commands

Eff:

```sh
cd eff
make run
make test
```

Koka:

```sh
cd koka
koka --include=src -e src/main.kk
koka --include=src -e test/state-test.kk
```

Haskell:

```sh
cd haskell
stack run state-example
stack test
```

## Correspondence

| 概念 | Eff | Koka | Haskell |
| --- | --- | --- | --- |
| effect signature | `effect Get`, `effect Set` | `effect state<s>` with `ctl get` / `ctl set` | `data StateF s next = Get (s -> next) \| Put s next` |
| read operation | `perform Get` | `get()` | `get :: Free (StateF s) s` |
| write operation | `perform (Set s)` | `set(s)` | `put :: s -> Free (StateF s) ()` |
| handler / interpreter | `handler ... finally ...` | `run-state(init, action)` | `runState :: s -> Free (StateF s) a -> (a, s)` |
| unhandled computation | 未処理 operation を含む計算 | `state<s>` を持つ direct-style 計算 | `Free (StateF s) a` の構文木 |
| continuation | handler clause の `k` | `ctl` clause の `resume` | `Get (s -> next)` の関数 |

## Notes

Eff 5.1 では operation をトップレベルに宣言します。そのため Eff 版では `effect Get : int` と `effect Set : int -> unit` を別々に書いていますが、ここでは同じ State signature に属する二つの operation として扱います。現在の Eff で確実に動くサンプルにするため、状態型は `int` に単相化しています。

Koka の `run-state` は、開いた effect row `<state<s>|e>` ではなく、閉じた `state<s>` を受け取ります。最初の比較を State 単独の理論に集中させるためです。handler 自体は、状態渡し関数 `s -> (a, s)` を組み立てる純粋な形で書いています。

Haskell 版では、signature functor と Free monad を直接定義しています。ライブラリで隠さず、operation signature から interpreter までの対応が見えるようにしています。

## Law Tests

各プロジェクトでは、代表的な State equation をテストしています。二つのプログラムを同じ初期状態で実行し、返り値と最終状態が一致することを確認します。

```text
get >>= put = return ()
put s >> put t = put t
put s >> get = put s >> return s
get >>= \s -> get >>= \t -> k s t
  =
get >>= \s -> k s s
```

ここでの等式テストは、State effect の law を処理系が自動的に保証していることを意味しません。テストしているのは、今回定義した `runState` handler / interpreter のもとで、二つのプログラムが同じ返り値と最終状態を持つ、という外延的な同値です。

## Tool Versions Checked

```text
Eff 5.1(Unix)
Koka 3.2.2
Stack 3.9.1
Stack resolver lts-22.43 (GHC 9.6.6)
```

Eff は upstream の OPAM pin でインストールしました。

```sh
opam pin add -k git eff https://github.com/matijapretnar/eff.git
```
