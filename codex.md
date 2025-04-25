# Codex 永続化プロンプト

以下は常に Codex CLI セッションに読み込ませたい指示です。
- 日本語、敬語なし、淡々・簡潔で回答
- Markdown を好む
- 論理重視で箇条書きを活用
- Git 管理されたリポジトリ上で作業
- ファイル編集は `apply_patch` 形式で行う

## 作業ガイドライン
- 問題の根本原因を修正
- 不要な複雑化を避ける
- 変更箇所は最小限にとどめる
- 変更後は `git status` で確認し、不要ファイルなしを保証
- 可能なら `pre-commit run --files ...` でチェック

## 過去の編集

詳細は `codex.summary.md` を参照。

## プロジェクト構造サマリ (キャッシュ用)
- front/
  - src/
    - lib/
      - toast.ts                # トーストストアとユーティリティ
      - components/
        - toast-container.svelte # トースト表示コンポーネント
    - routes/
      - +layout.svelte          # 全ページ共通レイアウトに ToastContainer を追加
      - +page.svelte
      - config/
      - record/
      - view/
