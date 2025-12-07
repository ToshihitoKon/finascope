<script lang="ts">
  import { Button, Pagination } from '$lib/components';

  // ページネーション用の状態
  let currentPage = $state(1);
  const totalItems = 100;
  const itemsPerPage = 10;
</script>

<div>
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

  <!-- 一括削除/ページネーション -->
  <div class="mt-4 flex items-center justify-between">
    <div class="flex items-center space-x-2">
      <Button variant="danger">選択項目を削除</Button>
    </div>

    <!-- ページネーション -->
    <Pagination count={totalItems} perPage={itemsPerPage} bind:page={currentPage} />
  </div>
</div>
