<script lang="ts">
  import { onMount } from 'svelte';
  import { NumberDateField } from '$lib/components';
  import type { Record, Category, PaymentMethod } from '$lib/api/v1/types';
  import * as api from '$lib/api/v1';
  import { States, RecordTypes, TodoIds } from '$lib/api/v1/const';
  import { toast } from 'svelte-sonner';
  import { selectedMonthRange } from '$lib/stores/selectedMonth';

  let records = $state<Record[]>([]);
  let categories = $state<Category[]>([]);
  let paymentMethods = $state<PaymentMethod[]>([]);

  interface DateValue { year: number; month: number; day: number; }

  // 新規入力フォーム
  const _today = new Date();
  let newDate = $state<DateValue | undefined>({ year: _today.getFullYear(), month: _today.getMonth() + 1, day: _today.getDate() });
  let newAmount = $state<number | undefined>(undefined);
  let newCategoryId = $state<string>(TodoIds.Category);
  let newPaymentMethodId = $state<string>(TodoIds.PaymentMethod);
  let newTitle = $state<string>('');
  let newTypeId = $state<number>(0);
  let newStateId = $state<number>(0);

  async function loadRecords(beginDate: string, endDate: string) {
    const res = await api.fetchRecords(beginDate, endDate);
    records = res.records;
  }

  $effect(() => {
    loadRecords($selectedMonthRange.beginDate, $selectedMonthRange.endDate);
  });

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
    if (!newDate) {
      toast.error('日付が不正です');
      return;
    }
    if (newAmount === undefined || newAmount <= 0 || !newTitle.trim()) {
      toast.error('金額・用途を入力してください');
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
      const _r = new Date();
      newDate = { year: _r.getFullYear(), month: _r.getMonth() + 1, day: _r.getDate() };
      newAmount = undefined;
      newTitle = '';
      newTypeId = 0;
      newStateId = 0;
      if (categories.length > 0) newCategoryId = categories[0].id;
      if (paymentMethods.length > 0) newPaymentMethodId = paymentMethods[0].id;

      await loadRecords($selectedMonthRange.beginDate, $selectedMonthRange.endDate);
    } catch {
      toast.error('レコードの作成に失敗しました');
    }
  }
</script>

<div class="layout-details">
  <h2>明細一覧</h2>
  <div class="layout-table-scroll">
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
          <td><span>{record.date.split('-')[0]}</span><span class="style-date-sep">/</span><span>{record.date.split('-')[1]}</span><span class="style-date-sep">/</span><span>{record.date.split('-')[2]}</span></td>
          <td><span>{record.type}</span></td>
          <td class="layout-money"><span>¥{record.amount.toLocaleString()}</span></td>
          <td class="layout-category"><span>{record.category}</span></td>
          <td class="layout-payment-method"><span>{record.payment_method}</span></td>
          <td><span>{record.state}</span></td>
          <td class="layout-title"><span>{record.title}</span></td>
          <td></td>
        </tr>
      {/each}

      <!-- 新規入力行 -->
      <tr class="style-new-row">
        <td><input type="checkbox" disabled /></td>
        <td><NumberDateField bind:value={newDate} /></td>
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
        <td class="layout-category">
          <select bind:value={newCategoryId}>
            <option value={TodoIds.Category}>TODO</option>
            {#each categories as cat (cat.id)}
              <option value={cat.id}>{cat.label}</option>
            {/each}
          </select>
        </td>
        <td class="layout-payment-method">
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
        <td class="layout-title">
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
</div><!-- layout-details -->

<style>
  .layout-details {
    width: 100%;
  }

  .layout-details h2 {
    margin: 0 0 16px;
    font-size: 1rem;
    font-weight: 700;
    color: #1f2937;
    letter-spacing: 0.02em;
  }

  .layout-table-scroll {
    overflow-x: auto;
    width: 100%;
    scrollbar-width: none;
  }

  .layout-table-scroll::-webkit-scrollbar {
    display: none;
  }

  .style-table {
    border-collapse: collapse;
    width: 100%;
    max-width: 960px;
    min-width: 800px;
  }

  .style-table th {
    background-color: var(--color-table-header-bg);
    padding: 8px 16px;
    white-space: nowrap;
    border-bottom: 1px solid var(--color-border);
    font-size: 0.75rem;
    font-weight: 600;
    color: var(--color-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }

  .style-table td {
    padding: 8px 16px;
    height: 36px;
    white-space: nowrap;
    vertical-align: middle;
    text-align: center;
    border-bottom: 1px solid var(--color-border);
  }

  .style-date-sep {
    padding: 0 2px;
    color: var(--color-text-muted);
  }

  .style-table td:nth-child(2),
  .layout-title {
    text-align: left;
  }

  .style-new-row {
    background-color: var(--color-table-header-bg);
  }

  .style-table input[type='text'],
  .style-table input[type='number'],
  .style-table select {
    width: 100%;
    padding: 4px 8px;
    border: none;
    border-bottom: 1px solid var(--color-border);
    box-sizing: border-box;
    font-size: 0.875rem;
    font-family: inherit;
    height: 28px;
    background-color: transparent;
    color: inherit;
    outline: none;
    vertical-align: middle;
    transition: border-color 0.15s, background-color 0.15s;
  }

  .style-table input[type='text']:focus,
  .style-table input[type='number']:focus,
  .style-table select:focus {
    border-bottom-color: var(--color-primary);
    background-color: rgba(255, 255, 255, 0.6);
  }

  .style-table input::placeholder {
    color: #bbb;
  }

  .style-table input[type='number']::-webkit-inner-spin-button,
  .style-table input[type='number']::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  .style-table input[type='number'] {
    appearance: textfield;
    -moz-appearance: textfield;
  }

  .style-table select {
    min-width: 80px;
    appearance: none;
    -webkit-appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6' viewBox='0 0 10 6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%23bbb'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 8px center;
    padding-right: 24px;
    cursor: pointer;
  }

  .layout-money {
    text-align: right;
    min-width: 100px;
  }

  .layout-category {
    min-width: 130px;
  }

  .layout-payment-method {
    min-width: 170px;
  }

  .layout-title {
    max-width: 300px;
    min-width: 150px;
    white-space: normal;
    word-break: break-all;
  }

  .layout-center {
    text-align: center;
  }

  .style-button {
    background-color: transparent;
    color: var(--color-primary);
    border: 1px solid var(--color-primary);
    border-radius: 4px;
    padding: 3px 10px;
    cursor: pointer;
    font-size: 0.8rem;
  }

  .style-button:hover {
    background-color: var(--color-primary);
    color: white;
  }

  .style-button-danger {
    color: #dc3545;
    border-color: #dc3545;
  }

  .style-button-danger:hover {
    background-color: #dc3545;
    color: white;
  }
</style>
