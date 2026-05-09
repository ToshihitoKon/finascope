---
name: update-issue-dependencies
description: issue が close されたとき、その issue を Blocked-by として参照している open issue の依存関係を再評価し、全前提が解決済みなら ready-to-start ラベルを付与するスキル。「issue を閉じた」「PR をマージした」「ready-to-start を付与したい」「依存関係を更新して」などの発言時に使う。作業完了時の運用フックとして必ず呼び出すこと。
---

# update-issue-dependencies

issue 間の依存グラフ（`Depends-on:` / `Blocked-by:`）と GitHub ラベルの整合性を保つためのスキル。issue を close した直後、または PR がマージされて issue が自動 close された直後に実行する。

## このスキルが解決する課題

前提 issue が closed になっても、依存している issue の `pending: blocked by related issue` ラベルが外れず `ready-to-start` も付与されないため、着手可能な issue を見落とす。

## ワークフロー

### Step 1: 起点となる closed issue を特定する

直近で closed になった issue を `CLOSED_ISSUE` とする。複数あれば各々について Step 2 以降を繰り返す。

### Step 2: CLOSED_ISSUE を Blocked-by として参照している issue を列挙する

open な issue の本文に `Blocked-by: #<CLOSED_ISSUE>` を含むものを抽出する。

```bash
gh issue list --repo <owner>/<repo> --state open \
  --search "Blocked-by: #<CLOSED_ISSUE> in:body" \
  --json number,body,labels
```

該当する open issue を `CANDIDATE_ISSUES` とする。空ならスキル終了。

### Step 3: 各候補の前提 issue の状態を全件確認する

各 CANDIDATE について、その本文に記載された **すべての** `Blocked-by:` `Depends-on:` 行を抽出する。issue 本文の規約として、依存関係は本文先頭の `## 依存関係` セクションに以下の形式で書かれている：

```
## 依存関係

- Blocked-by: #X — 理由
- Depends-on: #Y (closed: YYYY-MM-DD) — 理由
```

抽出したすべての前提 issue 番号について、`gh issue view <N> --json state` で state を確認する。

### Step 4: 全前提が closed なら ready-to-start を付与

候補 issue の前提 issue が **すべて closed** であれば：

1. `pending: blocked by related issue` ラベルがあれば外す
2. `ready-to-start` ラベルを付ける（存在しなければ作成: `gh label create "ready-to-start" --color "0E8A16" --description "前提となる別 issue が解決済みで着手可能"`）
3. 本文の `Blocked-by: #X` 行を `Depends-on: #X (closed: YYYY-MM-DD)` 形式に書き換える

1 件でも前提が open なら、その候補はスキップしてラベルもそのままにする。

### Step 5: 結果を報告する

ユーザーに以下を報告する：

- 評価対象の CANDIDATE_ISSUES
- うちアンブロックされた issue 番号と、外したラベル / 付与したラベル
- スキップされた候補と理由（どの Blocked-by がまだ open か）

## 補足

- `gh issue list --search` の挙動上、本文中の `#41` のような参照は他の文脈でもヒットしうるため、必ず `## 依存関係` セクションの行を確認してから判定する
- 1 つの PR が複数 issue を close する場合は、close された issue ごとに Step 2 以降を繰り返す
- このスキルは破壊的変更を行うため、該当 issue が多い場合は事前にユーザーに確認する
