<script lang="ts">
  import { Button } from '$lib/components';
</script>

<!-- メインページ：家計簿アプリ -->
<div class="min-h-screen bg-gray-50">
  <div class="mx-auto max-w-7xl space-y-8 px-4 py-6">
    <!-- 今月の支出合計コンポーネント -->
    <div class="card p-6">
      <h2 class="section-heading mb-2">今月の支出</h2>
      <p class="amount-display text-3xl">¥0</p>

      <!-- 主要カテゴリ -->
      <h2 class="section-heading my-4">主要カテゴリ</h2>
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

      <!-- 支払方法別サマリーコンポーネント -->
      <h2 class="section-heading my-4">支払方法別サマリー</h2>
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
              <th class="px-4 py-3 text-left">
                <span class="meta-info">日付</span>
              </th>
              <th class="px-4 py-3 text-left">
                <span class="meta-info">金額</span>
              </th>
              <th class="px-4 py-3 text-left">
                <span class="meta-info">カテゴリ</span>
              </th>
              <th class="px-4 py-3 text-left">
                <span class="meta-info">支払方法</span>
              </th>
              <th class="px-4 py-3 text-left">
                <span class="meta-info">摘要</span>
              </th>
              <th class="px-4 py-3 text-left">
                <span class="meta-info">操作</span>
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <!-- サンプルデータ行 -->
            <tr class="table-row">
              <td class="px-4 py-3">
                <input type="checkbox" class="checkbox" />
              </td>
              <td class="px-4 py-3">
                <span class="table-data">2024-12-27</span>
              </td>
              <td class="px-4 py-3">
                <span class="amount-display">¥1,200</span>
              </td>
              <td class="px-4 py-3">
                <span class="table-data">食費</span>
              </td>
              <td class="px-4 py-3">
                <span class="table-data">現金</span>
              </td>
              <td class="px-4 py-3">
                <span class="table-meta">昼食</span>
              </td>
              <td class="px-4 py-3">
                <Button variant="link">編集</Button>
              </td>
            </tr>

            <!-- 新規入力行1 -->
            <tr class="table-input-row">
              <td class="px-4 py-3">
                <span class="meta-info text-xs">新規1</span>
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
                <Button variant="danger" size="sm">削除</Button>
              </td>
            </tr>

            <!-- 新規入力行2 -->
            <tr class="table-input-row">
              <td class="px-4 py-3">
                <span class="meta-info text-xs">新規2</span>
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
                <Button variant="danger" size="sm">削除</Button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- 一括操作 -->
      <div class="mb-4 mt-4 flex items-center justify-center">
        <div class="flex items-center space-x-4">
          <Button variant="primary">記入済みを一括追加</Button>
          <Button variant="secondary">入力行を追加</Button>
        </div>
      </div>

      <!-- ページネーション/一括削除 -->
      <div class="mt-4 flex items-center justify-between">
        <div class="flex items-center space-x-2">
          <Button variant="danger">選択項目を削除</Button>
        </div>
        <div class="flex items-center space-x-2">
          <span class="meta-info">1-10 / 100件</span>
          <Button variant="secondary" size="sm">前へ</Button>
          <Button variant="secondary" size="sm">次へ</Button>
        </div>
      </div>
    </div>
  </div>
</div>
