# Finascope API

- Grape
- Rack

## Execute for development

```shell
$ bundle install
$ bundle exec rerun -- rackup
```

## セキュリティ設計

User のレコードの特定を避けるため、以下のルールを用いてデータを暗号化する：

- ユーザーから受け取るのは firebase auth の uid
- レコードの user_id は uid を元に salt をつけた hash とする
- ユーザーデータとテーブルのリレーション分離のため、ユーザーデータテーブルのみ専用の salt を使用
- 他のレコードとユーザーデータテーブル間のリレーションは作成しない
