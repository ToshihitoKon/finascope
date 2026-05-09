# 0012 Exceptions モジュールを真の例外クラス階層に再設計

> **scope**: api | **date**: 2026-05-09 | **issue**: #48

## 概要

`api/lib/exceptions.rb` で `StandardError.exception("...")` で生成された「メッセージ付きインスタンス」を、独立した例外クラスに置き換え、Grape の `rescue_from` で型別ハンドリングを可能にする。

## 目標

- `Exceptions::InvalidArgument` などを独自クラスにし、`rescue Exceptions::NotFound => e` のような型分岐ができる構造にする
- 利用側の `raise Exceptions::X.exception("msg")` を Ruby 標準の `raise Exceptions::X, "msg"` 形に統一する
- Firebase JWT デコード失敗を `Exceptions::Unauthorized` で raise するよう修正（階層化の効果を活かした最小限の意味修正）
- 例外クラス階層の継承関係を確認する spec を追加する

## 非目標

- 全 HTTP ステータスへの完全 mapping (NotFound→404, InvalidArgument→400, …) — これは後続 issue #49（エラー規約）で扱う
- 既存の `rescue StandardError => e` (`api/app/api/root.rb:30`) の全面的な書き換え — `request_userdata` 内の JWT デコード失敗ハンドリングは現状維持
- `Exceptions::NotFound` を未使用箇所（`update`/`delete` の id 不在ケース）に新規適用すること — これは別 issue #41 が扱う
- Service / Repository 層の責務再整理 — #50 のスコープ

## 設計

### 例外クラス階層

`api/lib/exceptions.rb` をフラットな個別クラス継承に置き換える。中間 `Base` を挟まずシンプルさを優先する。

```ruby
# frozen_string_literal: true

module Exceptions
  class InternalServerError < StandardError; end
  class InvalidArgument < StandardError; end
  class NotFound < StandardError; end
  class Unauthorized < StandardError; end
end
```

**設計判断:**

- 中間 Base を挟まない理由: 現状エラーは 4 種のみで、共通の振る舞いを持たせる予定もないため、`Exceptions::Base` を挟む価値が低い。型分岐は個別クラスで十分達成できる。
- `frozen_string_literal: true` は既存維持。
- すべて `StandardError` 直下で、各クラスは空実装（メッセージは `raise` 時に渡す）。

### 利用側の書き換え

`raise Exceptions::X.exception("msg")` → `raise Exceptions::X, "msg"` に統一する。引数なしの `raise Exceptions::InvalidArgument` 形（`payment_methods.rb:34`）はそのままで動作する（Ruby 標準）。

**変更パターン:**

| Before | After |
|--------|-------|
| `raise Exceptions::InvalidArgument.exception("no params to update")` | `raise Exceptions::InvalidArgument, "no params to update"` |
| `raise Exceptions::InternalServerError.exception("failed to ...")` | `raise Exceptions::InternalServerError, "failed to ..."` |
| `raise Exceptions::InvalidArgument` | `raise Exceptions::InvalidArgument`（変更なし） |

### Firebase JWT デコード失敗の例外型修正

`api/lib/firebase.rb` の `JWT::DecodeError` ハンドリングは現在 `Exceptions::InternalServerError` で再 raise しているが、JWT デコード失敗は本来 401 (Unauthorized) であり 500 (InternalServerError) は意味的に誤り。クラス階層化のついでに `Exceptions::Unauthorized` に修正する。

**現状（`api/lib/firebase.rb:40-42`）:**
```ruby
rescue JWT::DecodeError => e
  raise Exceptions::InternalServerError.exception("failed to decode JWT: #{e}")
end
```

**変更後:**
```ruby
rescue JWT::DecodeError => e
  raise Exceptions::Unauthorized, "failed to decode JWT: #{e}"
end
```

`api/app/api/root.rb:28-33` の `rescue StandardError => e` は現状維持。`Exceptions::Unauthorized` は `StandardError` 継承なのでこの rescue で問題なく捕捉され、401 を返す挙動は変わらない。型別 rescue_from の整備は #49 のスコープに委ねる。

### テスト

`api/spec/lib/exceptions_spec.rb` を新規作成し、各例外クラスが `StandardError` を継承していること、メッセージ付き raise が動作することを確認する。

```ruby
require "spec_helper"
require "lib/exceptions"

RSpec.describe Exceptions do
  describe "クラス階層" do
    it "InvalidArgument は StandardError を継承する" do
      expect(Exceptions::InvalidArgument.ancestors).to include(StandardError)
    end
    # 他 3 クラスも同様
  end

  describe "raise の挙動" do
    it "メッセージ付きで raise できる" do
      expect { raise Exceptions::NotFound, "missing" }
        .to raise_error(Exceptions::NotFound, "missing")
    end

    it "型による rescue が機能する" do
      expect {
        begin
          raise Exceptions::InvalidArgument, "bad"
        rescue Exceptions::NotFound
          # 捕捉されない
        end
      }.to raise_error(Exceptions::InvalidArgument)
    end
  end
end
```

既存のサービス層 spec が引き続き通ることが受け入れ条件。

## 変更ファイル一覧

- `api/lib/exceptions.rb` — クラス階層に置換
- `api/lib/firebase.rb` — `JWT::DecodeError` を `Exceptions::Unauthorized` で raise（行 41）。`raise Exceptions::InternalServerError.exception(...)` も新形式に置換（行 24）
- `api/db/repositories.rb` — `raise Exceptions::InternalServerError.exception(...)` を新形式に置換（行 84, 90, 202, 230, 270, 276）
- `api/services/invoice_records.rb` — 行 25, 36, 86 を新形式に置換
- `api/services/categories.rb` — 行 40 を新形式に置換
- `api/services/payment_methods.rb` — 行 34（変更不要、引数なし）, 行 45 を新形式に置換
- `api/services/records.rb` — 行 75 を新形式に置換
- `api/spec/lib/exceptions_spec.rb` — 新規、階層と raise 挙動の spec

## 実装ステップ

各ステップを独立コミットにできる順序で書く。

1. `api/lib/exceptions.rb` をクラス階層に置換
2. `api/spec/lib/exceptions_spec.rb` を追加し、新階層が動作することをテストで担保
3. 利用側 6 ファイル（`firebase.rb` / `repositories.rb` / `services/*.rb`）の `raise X.exception("msg")` を `raise X, "msg"` に一括置換
4. `firebase.rb` の `JWT::DecodeError` ハンドリングを `Exceptions::Unauthorized` に変更
5. RSpec 全体を実行し、既存サービス層 spec を含めて全部緑になることを確認
6. RuboCop / 型チェック相当のリンタを実行（`api/` には RuboCop あり）

## 代替案

### 案 A: 中間 `Exceptions::Base` を挟む

```ruby
class Base < StandardError; end
class InvalidArgument < Base; end
```

**却下理由:** Grape の `rescue_from Exceptions::Base` で「Exceptions 系全部」を一括キャッチする使い方を想定すれば有用だが、現状その用途がなく、後から必要になれば階層を一段足すのは容易。今は最小構造を採る。

### 案 B: 3 階層（Client/Server を中間に置く）

`ClientError`（4xx 想定）と `ServerError`（5xx 想定）を中間に挟む。

**却下理由:** HTTP ステータス対応は #49 のスコープであり、階層に意味を持たせるなら #49 と一緒に設計すべき。今 #48 のスコープで先取りすると #49 の設計余地を狭める。

### 案 C: `.exception("msg")` 記法を残す

クラス化しても `.exception("msg")` は ClassMethod として動くため後方互換は保たれる。

**却下理由:** Ruby 標準の `raise Class, "msg"` 形に揃えた方が他コードベースと一貫性がある。混在は将来の混乱要因。

## 未解決事項

- なし。後続 issue #49 で HTTP ステータス mapping を扱う際、本 doc で導入したクラス階層を前提に rescue_from を整備する。
