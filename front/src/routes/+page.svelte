<script lang="ts">
</script>

<!-- メインページ：家計簿アプリ -->
<div class="min-h-screen bg-gray-50">
  <!-- ページヘッダー -->
  <div class="mx-auto max-w-7xl px-4 py-6">
    <h1 class="page-title mb-6">家計簿</h1>
  </div>

  <div class="mx-auto max-w-7xl px-4 py-6 space-y-8">
    <!-- 今月の支出合計コンポーネント -->
    <div class="card p-6">
      <h2 class="section-heading mb-2">今月の支出</h2>
      <p class="amount-display text-3xl">¥0</p>
    </div>

    <!-- 主要カテゴリコンポーネント -->
    <div class="card p-6">
      <h2 class="section-heading mb-4">主要カテゴリ</h2>
      <div class="table-container">
        <table class="w-full">
          <thead class="table-header">
            <tr>
              <th class="px-4 py-2 text-left">
                <span class="meta-info">カテゴリ</span>
              </th>
              <th class="px-4 py-2 text-right">
                <span class="meta-info">金額</span>
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <tr class="table-row">
              <td class="px-4 py-2">
                <span class="category-label">食費</span>
              </td>
              <td class="px-4 py-2 text-right">
                <span class="amount-display">¥0</span>
              </td>
            </tr>
            <tr class="table-row">
              <td class="px-4 py-2">
                <span class="category-label">交通費</span>
              </td>
              <td class="px-4 py-2 text-right">
                <span class="amount-display">¥0</span>
              </td>
            </tr>
            <tr class="table-row">
              <td class="px-4 py-2">
                <span class="category-label">日用品</span>
              </td>
              <td class="px-4 py-2 text-right">
                <span class="amount-display">¥0</span>
              </td>
            </tr>
            <tr class="table-row">
              <td class="px-4 py-2">
                <span class="category-label">その他</span>
              </td>
              <td class="px-4 py-2 text-right">
                <span class="amount-display">¥0</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 支払方法別サマリーコンポーネント -->
    <div class="card p-6">
      <h2 class="section-heading mb-4">支払方法別サマリー</h2>
      <div class="grid grid-cols-1 gap-4 md:grid-cols-3 lg:grid-cols-4">
        <div class="card p-4">
          <h3 class="category-label">現金</h3>
          <p class="amount-display">¥0</p>
        </div>
        <div class="card p-4">
          <h3 class="category-label">クレジットカード</h3>
          <p class="amount-display">¥0</p>
          <p class="meta-info">引き落とし: 27日</p>
        </div>
        <div class="card p-4">
          <h3 class="category-label">電子マネー</h3>
          <p class="amount-display">¥0</p>
        </div>
      </div>
    </div>

    <!-- 明細一覧コンポーネント -->
    <div class="card p-6">
      <h2 class="section-heading mb-4">明細一覧</h2>

      <div class="table-container">
        <table class="w-full">
          <thead class="table-header">
            <tr>
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500"
              >
                <input type="checkbox" class="checkbox" />
              </th>
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500"
                >日付</th
              >
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500"
                >金額</th
              >
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500"
                >カテゴリ</th
              >
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500"
                >支払方法</th
              >
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500"
                >摘要</th
              >
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500"
                >操作</th
              >
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <!-- サンプルデータ行 -->
            <tr class="table-row">
              <td class="px-4 py-3">
                <input type="checkbox" class="checkbox" />
              </td>
              <td class="px-4 py-3 text-sm text-gray-900">2024-12-27</td>
              <td class="px-4 py-3 text-sm font-semibold text-gray-900">¥1,200</td>
              <td class="px-4 py-3 text-sm text-gray-900">食費</td>
              <td class="px-4 py-3 text-sm text-gray-900">現金</td>
              <td class="px-4 py-3 text-sm text-gray-500">昼食</td>
              <td class="px-4 py-3 text-sm">
                <button class="link-accent mr-2">編集</button>
                <button class="btn-danger">削除</button>
              </td>
            </tr>

            <!-- 新規入力行（テーブル最下部） -->
            <tr class="table-input-row">
              <td class="px-4 py-3">
                <span class="text-xs text-gray-500">新規</span>
              </td>
              <td class="px-4 py-3">
                <input
                  type="date"
                  class="form-input w-full px-2 py-1"
                  value={new Date().toISOString().split('T')[0]}
                />
              </td>
              <td class="px-4 py-3">
                <input type="number" placeholder="金額" class="form-input w-full px-2 py-1" />
              </td>
              <td class="px-4 py-3">
                <select class="form-select w-full px-2 py-1">
                  <option value="">カテゴリを選択</option>
                  <option value="food">食費</option>
                  <option value="transport">交通費</option>
                  <option value="daily">日用品</option>
                  <option value="other">その他</option>
                </select>
              </td>
              <td class="px-4 py-3">
                <select class="form-select w-full px-2 py-1">
                  <option value="">支払方法を選択</option>
                  <option value="cash">現金</option>
                  <option value="credit">クレジットカード</option>
                  <option value="emoney">電子マネー</option>
                </select>
              </td>
              <td class="px-4 py-3">
                <input type="text" placeholder="摘要" class="form-input w-full px-2 py-1" />
              </td>
              <td class="px-4 py-3">
                <button class="btn-primary px-3 py-1"> 追加 </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- ページネーション/一括操作 -->
      <div class="mt-4 flex items-center justify-between">
        <div class="flex items-center space-x-2">
          <button class="btn-danger text-sm">選択項目を削除</button>
        </div>
        <div class="flex items-center space-x-2">
          <span class="meta-info">1-10 / 100件</span>
          <button class="btn-secondary px-3 py-1">前へ</button>
          <button class="btn-secondary px-3 py-1">次へ</button>
        </div>
      </div>
    </div>
  </div>
</div>
