<script lang="ts">
  import { onMount } from 'svelte';
  import { DateField } from '$lib/components';
  import { today, getLocalTimeZone } from '@internationalized/date';
  import type { CalendarDate } from '@internationalized/date';
  import type { Record, Category, PaymentMethod } from '$lib/api/v1/types';
  import * as api from '$lib/api/v1/mock';
  import { States, RecordTypes, TodoIds } from '$lib/api/v1/const';
  import { toast } from 'svelte-sonner';

  interface Props {
    records: Record[];
    onRefresh?: () => void;
  }

  let { records, onRefresh }: Props = $props();

  let categories = $state<Category[]>([]);
  let paymentMethods = $state<PaymentMethod[]>([]);

  // 新規入力フォーム
  let newDate = $state<CalendarDate | undefined>(today(getLocalTimeZone()));
  let newAmount = $state<number | undefined>(undefined);
  let newCategoryId = $state<string>(TodoIds.Category);
  let newPaymentMethodId = $state<string>(TodoIds.PaymentMethod);
  let newTitle = $state<string>('');
  let newTypeId = $state<number>(0);
  let newStateId = $state<number>(0);

  onMount(async () => {
    const [categoriesRes, paymentMethodsRes] = await Promise.all([
      api.fetchCategories(),
      api.fetchPaymentMethods()
    ]);
    categories = categoriesRes.categories;
    paymentMethods = paymentMethodsRes.payment_methods;

    if (categories.length > 0) newCategoryId = categories[0].id;
    if (paymentMethods.length > 0) newPaymentMethodId = paymentMethods[0].id;
  });

  async function handleCreate() {
    if (!newDate || newAmount === undefined || newAmount <= 0 || !newTitle.trim()) {
      toast.error('日付・金額・用途を入力してください');
      return;
    }

    const dateStr = `${newDate.year}-${String(newDate.month).padStart(2, '0')}-${String(newDate.day).padStart(2, '0')}`;

    try {
      await api.createRecord({
        title: newTitle.trim(),
        type_id: newTypeId,
        state_id: newStateId,
        description: '',
        amount: newAmount,
        category_id: newCategoryId,
        payment_method_id: newPaymentMethodId,
        date: dateStr
      });
      toast.success('レコードを作成しました');

      // フォームリセット
      newDate = today(getLocalTimeZone());
      newAmount = undefined;
      newTitle = '';
      newTypeId = 0;
      newStateId = 0;
      if (categories.length > 0) newCategoryId = categories[0].id;
      if (paymentMethods.length > 0) newPaymentMethodId = paymentMethods[0].id;

      if (onRefresh) onRefresh();
    } catch {
      toast.error('レコードの作成に失敗しました');
    }
  }
</script>

<div class="layout-container">
  <h2>明細一覧</h2>
</div>

<div class="layout-container">
  <table class="style-table">
    <thead>
      <tr>
        <th></th>
        <th><span>日付</span></th>
        <th><span>種別</span></th>
        <th><span>金額</span></th>
        <th><span>カテゴリ</span></th>
        <th><span>支払方法</span></th>
        <th><span>状態</span></th>
        <th><span>用途</span></th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      {#each records as record (record.id)}
        <tr>
          <td><input type="checkbox" /></td>
          <td><span>{record.date}</span></td>
          <td><span>{record.type}</span></td>
          <td class="layout-money"><span>¥{record.amount.toLocaleString()}</span></td>
          <td><span>{record.category}</span></td>
          <td><span>{record.payment_method}</span></td>
          <td><span>{record.state}</span></td>
          <td><span>{record.title}</span></td>
          <td></td>
        </tr>
      {/each}

      <!-- 新規入力行 -->
      <tr class="style-new-row">
        <td><input type="checkbox" disabled /></td>
        <td><DateField bind:value={newDate} /></td>
        <td>
          <select bind:value={newTypeId}>
            {#each RecordTypes as rt (rt.id)}
              <option value={rt.id}>{rt.label}</option>
            {/each}
          </select>
        </td>
        <td class="layout-money">
          <input type="number" placeholder="金額" min="0" bind:value={newAmount} />
        </td>
        <td>
          <select bind:value={newCategoryId}>
            <option value={TodoIds.Category}>TODO</option>
            {#each categories as cat (cat.id)}
              <option value={cat.id}>{cat.label}</option>
            {/each}
          </select>
        </td>
        <td>
          <select bind:value={newPaymentMethodId}>
            <option value={TodoIds.PaymentMethod}>TODO</option>
            {#each paymentMethods as pm (pm.id)}
              <option value={pm.id}>{pm.label}</option>
            {/each}
          </select>
        </td>
        <td>
          <select bind:value={newStateId}>
            {#each States as s (s.id)}
              <option value={s.id}>{s.label}</option>
            {/each}
          </select>
        </td>
        <td>
          <input type="text" placeholder="用途" bind:value={newTitle} />
        </td>
        <td class="layout-center">
          <button class="style-button" onclick={handleCreate}>追加</button>
        </td>
      </tr>
    </tbody>
    <tfoot>
      <tr>
        <td colspan="8"></td>
        <td class="layout-center">
          <button class="style-button style-button-danger">一括削除</button>
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

  .style-table tbody > tr:nth-of-type(even):not(.style-new-row) {
    background-color: rgb(237 238 242);
  }

  .style-new-row {
    background-color: #f0f4ff;
  }

  .style-table input[type='text'],
  .style-table input[type='number'],
  .style-table select {
    width: 100%;
    padding: 2px 6px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
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

  .style-button:hover {
    opacity: 0.8;
  }

  .style-button-danger {
    background-color: #dc3545;
  }
</style>
