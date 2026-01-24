<script lang="ts">
  import { DateField } from '$lib/components';
  import type { Record } from '$lib/api/v1/types';

  interface Props {
    records: Record[];
  }

  let { records }: Props = $props();
</script>

<div class="layout-container">
  <h2>明細一覧</h2>
</div>

<div class="layout-container">
  <table class="style-table">
    <thead>
      <tr>
        <th></th>
        <th>
          <span>日付</span>
        </th>
        <th>
          <span>金額</span>
        </th>
        <th>
          <span>カテゴリ</span>
        </th>
        <th>
          <span>支払方法</span>
        </th>
        <th>
          <span>用途</span>
        </th>
        <th class="layout-center">
          <button class="style-button">編集</button>
        </th>
      </tr>
    </thead>
    <tbody>
      {#each records as record (record.id)}
        <tr>
          <td>
            <input type="checkbox" />
          </td>
          <td>
            <span>{record.date}</span>
          </td>
          <td class="layout-money">
            <span>¥{record.amount.toLocaleString()}</span>
          </td>
          <td>
            <span>{record.category}</span>
          </td>
          <td>
            <span>{record.payment_method}</span>
          </td>
          <td>
            <span>{record.title}</span>
          </td>
          <td> </td>
        </tr>
      {/each}

      <!-- 新規入力行1 -->
      <tr>
        <td>
          <input type="checkbox" disabled />
        </td>
        <td>
          <DateField />
        </td>
        <td class="layout-money">
          <input type="number" placeholder="金額" />
        </td>
        <td>
          <select></select>
        </td>
        <td>
          <select></select>
        </td>
        <td>
          <input type="text" placeholder="円盤" />
        </td>
        <td class="layout-center">
          <button class="style-button">削除</button>
        </td>
      </tr>
    </tbody>
    <tfoot>
      <tr>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td class="layout-center">
          <button class="style-button">一括削除</button>
        </td>
      </tr>
    </tfoot>
  </table>
</div>

<style>
  .layout-container {
    display: flex;
    justify-content: center;
  }

  .style-table {
    border-collapse: collapse;
    width: 100%;
    max-width: 960px;
  }

  .style-table th {
    background-color: var(--color-primary-bg);
    padding: 8px 16px;
  }

  .style-table td {
    padding: 8px 16px;
    height: 36px;
  }

  .style-table tbody > tr:nth-of-type(even) {
    background-color: rgb(237 238 242);
  }

  .layout-money {
    text-align: right;
  }

  .layout-center {
    text-align: center;
  }

  .style-button {
    background-color: var(--color-primary);
    color: white;
    border: none;
    border-radius: 8px;
    padding: 4px 8px;
    cursor: pointer;
  }
</style>
