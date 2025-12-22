<script lang="ts">
  import { Button } from '$lib/components';
</script>

<div>
  <h2 class="mb-4">明細一覧</h2>

  <div class="">
    <table class="w-full">
      <thead class="">
        <tr>
          <th class="px-4 py-3 text-left"></th>
          <th class="px-4 py-3 text-left">
            <span>日付</span>
          </th>
          <th class="px-4 py-3 text-left">
            <span>金額</span>
          </th>
          <th class="min-w-24 px-4 py-3 text-left">
            <span>カテゴリ</span>
          </th>
          <th class="min-w-48 px-4 py-3 text-left">
            <span>支払方法</span>
          </th>
          <th class="min-w-48 px-4 py-3 text-left">
            <span>何？</span>
          </th>
          <th class="min-w-12 px-4 py-3 text-left">
            <span></span>
          </th>
        </tr>
      </thead>
      <tbody class="">
        <!-- サンプルデータ行 -->
        <tr class="">
          <td class="px-4 py-3">
            <input type="checkbox" class="rounded" />
          </td>
          <td class="px-4 py-3">
            <span class="">2024-12-27</span>
          </td>
          <td class="px-4 py-3">
            <span class="">¥92,640</span>
          </td>
          <td class="px-4 py-3">
            <span class="">趣味</span>
          </td>
          <td class="px-4 py-3">
            <span class="">ANA Visa</span>
          </td>
          <td class="px-4 py-3">
            <span class="">Fanatec GT DD Pro</span>
          </td>
          <td class="min-w-24 px-4 py-3">
            <Button variant="primary">編集</Button>
          </td>
        </tr>

        <!-- 新規入力行1 -->
        <tr class="">
          <td class="px-4 py-3">
            <input type="checkbox" class="rounded" disabled />
          </td>
          <td class="px-4 py-3">
            <input
              type="date"
              class="w-full rounded border px-2 py-1 text-sm"
              value={new Date().toISOString().split('T')[0]}
            />
          </td>
          <td class="px-4 py-3">
            <input
              type="number"
              placeholder="金額"
              class="w-full rounded border px-2 py-1 text-sm"
            />
          </td>
          <td class="px-4 py-3">
            <select class="w-full rounded border px-2 py-1 text-sm"></select>
          </td>
          <td class="px-4 py-3">
            <select class="w-full rounded border px-2 py-1 text-sm"> </select>
          </td>
          <td class="px-4 py-3">
            <input type="text" placeholder="円盤" class="w-full rounded border px-2 py-1 text-sm" />
          </td>
          <td class="px-4 py-3">
            <Button variant="danger">削除</Button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
