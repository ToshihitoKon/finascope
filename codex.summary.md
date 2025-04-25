# Toast Notifications 機能追加 Summary

## 作業内容
- `front/src/lib/toast.ts` を追加
  - トースト用ストア `toasts` （`writable<Toast[]>`）を定義
  - `showToast(message, type?, duration?)` / `removeToast(id)` を実装
- `front/src/lib/components/toast-container.svelte` を追加
  - `$toasts` を購読し、スライド／フェードトランジション付きで表示
  - エラー時は `bg-destructive text-destructive-foreground` クラスを適用
  - 手動クローズボタンで即時削除可能
- `front/src/routes/+layout.svelte` を更新
  - `<ToastContainer />` をインポートしてレイアウト直下に配置

## 使用方法
任意のコンポーネントやページで以下のように呼び出すだけでトースト通知を表示できます。
```ts
import { showToast } from '$lib/toast';

// エラーメッセージ（赤背景）
showToast('エラーが発生しました', 'error');

// 成功メッセージ（緑背景）
showToast('保存が完了しました', 'success');

// 情報メッセージ（青背景）、3秒で消える
showToast('ロード中...', 'info', 3000);
```

- デフォルトの表示時間は 5000ms
- 自動消去に加え、右端の ✕ ボタンで手動削除も可能