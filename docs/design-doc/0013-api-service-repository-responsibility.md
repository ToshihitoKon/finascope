# 0013 Service ↔ Repository 責務再整理

> **scope**: api | **date**: 2026-05-09

## 概要

Repository に紛れ込んだドメインロジック（`calculate_closing_period`）と Service 層に置かれた整形ロジック（`format_record`）を切り出し、Service 間の直接結合（`Service::FinanceRecords.new` の埋め込み呼び出し）を解消する。

関連 issue: [#50](https://github.com/ToshihitoKon/finascope/issues/50)

## 背景

`CLAUDE.md` のレイヤリング方針では Repository は「データアクセス層」、Service は「ビジネスロジック層」と定義されている。現状は次の点で乖離している:

- `DB::Repository::FinanceRecord.calculate_closing_period` (`api/db/repositories.rb:14-55`) は DB アクセスを一切しない 40 行の日付計算で、コメントに `# TODO: thinking calculate_closing_period は本当に Repository の責務か？` という疑問が残されている
- `Service::InvoiceRecords` (`api/services/invoice_records.rb:109`) と `Service::View` (`api/services/view.rb:12`) が `Service::FinanceRecords.new` を内部で呼び出し、`format_record` を public メソッドとして借用している
- `Service::InvoiceRecords` だけが `@uid` を保持しているのは、後続で `FinanceRecords.new(uid: @uid)` するための非対称な構造

## 目標

- `calculate_closing_period` を Repository から切り離し、純粋なドメインロジックとして独立させる
- `format_record` を `Service::FinanceRecords` の public メソッドから切り離し、専用クラス `RecordFormatter` に移譲する
- `Service::InvoiceRecords` と `Service::View` から `Service::FinanceRecords.new` の埋め込み呼び出しを排除し、Service 間の直接結合を解消する
- リファクタリング前後で API レスポンスの内容が変わらないこと

## 非目標

- Entity 層への整形ロジック移譲（別 issue で扱う）
- API シグネチャ・レスポンスの変更
- `Service::FinanceRecords#format_record` の呼び出しサイトを除く既存ロジックの再設計
- ドメインモジュール用の新ディレクトリ作成（`api/domain/` 等）。今回は `api/lib/` にフラットに置く

## 設計

### ファイル配置の方針

新規ファイルは `api/lib/` 配下にフラットに置く。`user_hash.rb` / `firebase.rb` / `id.rb` 等の既存配置に合わせる形。今後ドメインクラスが増えた段階で `api/domain/` へ移すかを再検討する。

### ClosingPeriod モジュール

`api/lib/closing_period.rb` に純粋関数として実装する。状態を持たないのでクラスではなくモジュールメソッドにする。

```ruby
module ClosingPeriod
  # 戻り値: [begin_date, end_date]
  def self.calculate(year:, month:, closing_day_of_month:, withdrawal_day_of_month:)
    # 既存の calculate_closing_period の本体ロジックを移植
  end
end
```

呼び出し箇所:

- `Service::InvoiceRecords#withdrawal_records_aggregation` で `ClosingPeriod.calculate(...)` を直接呼ぶ
- `DB::Repository::FinanceRecord.calculate_closing_period` は削除する

### RecordFormatter クラス

`api/lib/record_formatter.rb` に実装する。`UserHash` を初期化時に受け取り、`format` で 1 レコードを整形する。

```ruby
class RecordFormatter
  def initialize(uhash:)
    @uhash = uhash
  end

  def format(record)
    # Service::FinanceRecords#format_record の本体を移植
  end
end
```

各 Service は `initialize` 内で `RecordFormatter.new(uhash: @uhash)` を生成して保持する。Service 間で `format_record` を借用しなくなるため、`Service::FinanceRecords#format_record` の `public` 化は解消する。

### Service の変更

#### `Service::FinanceRecords`

- `format_record` メソッドを削除し、`RecordFormatter` に委譲する
- `get_records` 内では `@formatter.format(record)` で整形する

#### `Service::InvoiceRecords`

- `@uid` の保持を廃止（`FinanceRecords.new(uid: @uid)` が不要になるため）
- `withdrawal_records_aggregation` 内で `Service::FinanceRecords.new(uid: @uid)` を生成しない。代わりに自身が保持する `@formatter` を使う
- `ClosingPeriod.calculate(...)` を直接呼ぶ

#### `Service::View`

- `@finance_records_service = Service::FinanceRecords.new(uid:)` を廃止
- 自身が保持する `@formatter` を使って `category_aggregation` 内のレコード整形を行う

### Repository の変更

`DB::Repository::FinanceRecord.calculate_closing_period` を削除する。それ以外の Repository メソッドは変更しない。

## 変更ファイル一覧

- `api/lib/closing_period.rb` — 新規作成。`ClosingPeriod.calculate` モジュールメソッド
- `api/lib/record_formatter.rb` — 新規作成。`RecordFormatter` クラス
- `api/db/repositories.rb` — `calculate_closing_period` を削除
- `api/services/finance_records.rb` — `format_record` を削除し、`@formatter` 経由で整形
- `api/services/invoice_records.rb` — `@uid` 保持と `Service::FinanceRecords.new` 呼び出しを削除、`ClosingPeriod.calculate` と `@formatter` を利用
- `api/services/view.rb` — `Service::FinanceRecords.new` 呼び出しを削除、`@formatter` を利用
- `api/spec/lib/closing_period_spec.rb` — 新規作成。`ClosingPeriod.calculate` のユニットテスト
- `api/spec/lib/record_formatter_spec.rb` — 新規作成。`RecordFormatter#format` のユニットテスト

## 実装ステップ

1. **ClosingPeriod モジュールの抽出**
   - `api/lib/closing_period.rb` を作成し、`calculate_closing_period` の本体を `ClosingPeriod.calculate(year:, month:, closing_day_of_month:, withdrawal_day_of_month:)` として移植
   - `api/spec/lib/closing_period_spec.rb` を作成。月末締め (-1)・締め日なし (0)・通常締め日 (closing < withdrawal / closing >= withdrawal)・`Date::Error` フォールバックの 4〜5 ケースを golden path として書く
   - `Service::InvoiceRecords#withdrawal_records_aggregation` の呼び出しを `ClosingPeriod.calculate(...)` に置き換え
   - `DB::Repository::FinanceRecord.calculate_closing_period` を削除
   - `bundle exec rspec` と `./scripts/test/api-test.sh` で既存 E2E が通ることを確認

2. **RecordFormatter クラスの抽出**
   - `api/lib/record_formatter.rb` を作成し、`Service::FinanceRecords#format_record` の本体を `RecordFormatter#format(record)` として移植
   - `api/spec/lib/record_formatter_spec.rb` を作成。encrypted_* が nil の TODO 扱い・通常レコードの decrypt + label 化 1 ケースずつを golden path として書く
   - `Service::FinanceRecords` で `@formatter = RecordFormatter.new(uhash: @uhash)` を `initialize` で生成し、`get_records` を `@formatter.format(record)` 経由に変更。`format_record` メソッドは削除

3. **Service::View の DI 化**
   - `Service::View#initialize` から `@finance_records_service = Service::FinanceRecords.new(uid:)` を削除
   - `@formatter = RecordFormatter.new(uhash: @uhash)` を生成して保持
   - `category_aggregation` 内の整形を `@formatter.format(record)` に置き換え

4. **Service::InvoiceRecords の DI 化と非対称構造の解消**
   - `@uid` の保持をやめる（`Service::FinanceRecords.new(uid: @uid)` が不要になったため）
   - `@formatter = RecordFormatter.new(uhash: @uhash)` を生成して保持
   - `withdrawal_records_aggregation` 内の `Service::FinanceRecords.new(uid: @uid)` 生成を削除し、`@formatter.format(record)` に置き換え

5. **検証**
   - `./scripts/test/api-test.sh` で全 spec が通ることを確認
   - `bundle exec rubocop` で lint が通ることを確認
   - 既存 E2E spec でレスポンス形が変わっていないことを確認

## 代替案

### calculate_closing_period の移設先

- **`Service::InvoiceRecords` の private メソッド化**: 唯一の呼び出し元なので閉じた責務にできるが、純粋なドメインロジックが Service 内に埋まる。将来的に他の Service から再利用したくなった際に再度切り出しが必要。今回は再利用性を優先してドメインモジュールに切り出す
- **`DB::Model::PaymentMethod` のインスタンスメソッド化**: 締め日・引き落とし日が `PaymentMethod` のフィールドなのでメソッドとして妥当だが、ActiveRecord モデルにビジネスロジックを載せる方針が他のモデルにも波及するため一旦見送る

### Service 間結合の解消方法

- **コンストラクタインジェクション**: `InvoiceRecords` / `View` の `initialize` で `FinanceRecords` を受け取る形。テスト容易性は高いが、本質的には「`format_record` を借用したいだけ」なので `RecordFormatter` への分離の方が責務が明確になる
- **共通モジュール化**: `format_record` をモジュール関数にして各 Service から `include` する。状態（`@uhash`）の扱いがやりにくく、結合が緩むだけで責務分離にならない

### ファイル配置

- **`api/domain/` 新設**: ドメイン層を明示的に独立させる構成だが、現状のドメインクラスは 2 つしかなく、`api/lib/` で十分。増えてきたら再検討する
- **`api/services/domain/`**: Service 配下に置くと「Service が使うヘルパー」と読まれやすく、独立した責務として育てづらい

## 未解決事項

- Entity 層への整形ロジック移譲（別 issue）の進捗次第では `RecordFormatter` をさらに薄くする方向もありうるが、それは当該 issue で扱う
- ドメインクラス・モジュールが増えた段階で `api/domain/` ディレクトリへの移行を検討する

---

## 実装サマリー

> **実装日**: 2026-05-09

### 変更ファイル

- `api/lib/closing_period.rb` — 新規作成。`ClosingPeriod.calculate(year:, month:, closing_day_of_month:, withdrawal_day_of_month:)` モジュールメソッドとして実装。`NO_CLOSING_DAY = 0` / `END_OF_MONTH = -1` 定数で分岐意図を表現
- `api/lib/record_formatter.rb` — 新規作成。`UserHash` を `initialize` で受け取り `format(record)` で整形する `RecordFormatter` クラス
- `api/db/repositories.rb` — `DB::Repository::FinanceRecord.calculate_closing_period` を削除
- `api/services/records.rb` — `Service::FinanceRecords#format_record` を削除し、`@formatter` 経由で整形するよう変更（ddoc に書いていた `api/services/finance_records.rb` は誤りで、実体ファイル名は `records.rb`）
- `api/services/view.rb` — `@finance_records_service = Service::FinanceRecords.new(uid:)` を廃止し `@formatter = RecordFormatter.new(uhash: @uhash)` に置換。`require_relative "records"` も削除
- `api/services/invoice_records.rb` — `@uid` 保持と `Service::FinanceRecords.new(uid: @uid)` 呼び出しを廃止。`ClosingPeriod.calculate(...)` を直接呼び、`@formatter` を保持してレコード整形
- `api/spec/lib/closing_period_spec.rb` — 新規作成。締め日 0 / -1 / closing < withdrawal / closing >= withdrawal / `Date::Error` フォールバックの 5 ケース
- `api/spec/lib/record_formatter_spec.rb` — 新規作成。`UserHash` を `instance_double` でスタブし、フル populated レコードと `encrypted_*` が nil の TODO 扱いの 2 ケース

### 実装内容

ddoc の設計ステップ 1〜5 をそのまま実施。`ClosingPeriod` の抽出 → `RecordFormatter` の抽出 → `Service::FinanceRecords` 内部利用の置換 → `Service::View` の DI 化 → `Service::InvoiceRecords` の DI 化と非対称構造解消、の順に進めた。

設計通り進んだ点:

- `ClosingPeriod` は状態を持たない純粋関数なのでクラスでなくモジュールメソッドとした
- `RecordFormatter` は `UserHash` を `initialize` で受け取る形にし、各 Service が自前で生成して保持する設計に統一
- `api/lib/` 配下にフラットに配置（`api/domain/` は作らず）
- API のレスポンス内容は変更していないため、既存 E2E spec が無修正で通ることを確認

設計と異なった点:

- ddoc では `api/services/finance_records.rb` と書いていたが、実体ファイル名は `api/services/records.rb`（クラス名とファイル名がずれている既存状態）。今回は実体に合わせて修正し、ファイル名のリネームは別変更とする

### 確認・検証

- `./scripts/test/api-test.sh`: **21 examples, 0 failures**（既存 E2E + 新規ユニット 7 ケース）
- 変更ファイル 8 個に対する `bundle exec rubocop`: offense なし
- API レスポンス形の互換性は既存 E2E spec の通過で確認

### 気づき・備考

- `Service::FinanceRecords` のファイル名（`records.rb`）とクラス名（`FinanceRecords`）の不一致は今回の責務再整理とは別軸のため触らなかった。リネームは別 PR で扱うのが自然
- `RecordFormatter` を切り出したことで、`Service::FinanceRecords` への依存が `format_record` 借用目的では消滅した。一方で `Service::InvoiceRecords` には `calc_withdrawal_date` 等の private メソッドが残っており、こちらも純粋計算なのでドメインモジュール候補（今後 `api/lib/` のドメインクラスが増えた段階で `api/domain/` 新設と合わせて検討）
- 実装中、コード内のマルチバイト文字を新規に書かない方針を CLAUDE.md に追記する判断があり、別コミットで反映。spec ファイルでは `Constants.record_type(...)[:label]` 経由でラベルを参照することで spec ファイル本体に日本語リテラルを書かない形に統一した
- 今回新規追加した spec は `api/spec/lib/` 配下に置いた。既存の `exceptions_spec.rb` と同階層で違和感なく収まっている
