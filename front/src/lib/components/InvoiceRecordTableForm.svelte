<script lang="ts">
  import type { InvoiceRecord, PaymentMethod } from '$lib/api/v1/types';
  import * as api from '$lib/api/v1';
  import { toast } from 'svelte-sonner';

  interface Props {
    paymentMethods: PaymentMethod[];
    year: number;
    month: number;
    onRefresh?: () => void;
  }

  let { paymentMethods, year, month, onRefresh }: Props = $props();

  // InvoiceRecordsをPaymentMethodごとにマッピング
  let invoiceRecordsByPaymentMethod = $state<Map<string, InvoiceRecord>>(new Map());
  let loading = $state(true);

  // 編集中の行
  let editingPaymentMethodId = $state<string | null>(null);
  let editingData = $state<{ amount: number; state_id: number }>({ amount: 0, state_id: 1 });

  // 指定月のInvoiceRecordsを取得
  async function loadInvoiceRecords() {
    loading = true;
    try {
      // 指定月の引き落とし日の範囲を計算
      const beginDate = new Date(year, month - 1, 1).toISOString().split('T')[0];
      const endDate = new Date(year, month, 0).toISOString().split('T')[0];

      const query = `withdrawal_date_begin=${beginDate}&withdrawal_date_end=${endDate}`;
      const response = await api.fetchInvoiceRecords(query);

      // PaymentMethodごとにマッピング
      const map = new Map<string, InvoiceRecord>();
      response.records.forEach((record) => {
        map.set(record.payment_method_id, record);
      });
      invoiceRecordsByPaymentMethod = map;
    } catch (error) {
      toast.error('請求レコードの取得に失敗しました');
    } finally {
      loading = false;
    }
  }

  // 年月が変わったらリロード
  $effect(() => {
    loadInvoiceRecords();
  });

  // 引き落とし日を計算（PaymentMethodのwithdrawal_day_of_monthから）
  function calculateWithdrawalDate(pm: PaymentMethod): string {
    let day = pm.withdrawal_day_of_month;

    if (day === -1) {
      // 月末
      const lastDay = new Date(year, month, 0).getDate();
      return `${year}-${String(month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;
    } else if (day === 0) {
      // 指定なし → 月初
      return `${year}-${String(month).padStart(2, '0')}-01`;
    } else {
      // 指定日
      return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    }
  }

  async function handleCreate(paymentMethodId: string) {
    const pm = paymentMethods.find((p) => p.id === paymentMethodId);
    if (!pm) return;

    try {
      await api.createInvoiceRecord({
        amount: 0,
        state_id: 1,
        payment_method_id: paymentMethodId,
        withdrawal_date: calculateWithdrawalDate(pm)
      });
      toast.success('請求レコードを作成しました');

      await loadInvoiceRecords();
      if (onRefresh) onRefresh();
    } catch (error) {
      toast.error('請求レコードの作成に失敗しました');
    }
  }

  async function handleDelete(id: string) {
    try {
      await api.deleteInvoiceRecord({ id });
      toast.success('請求レコードを削除しました');

      await loadInvoiceRecords();
      if (onRefresh) onRefresh();
    } catch (error) {
      toast.error('請求レコードの削除に失敗しました');
    }
  }

  function startEdit(record: InvoiceRecord) {
    editingPaymentMethodId = record.payment_method_id;
    editingData = {
      amount: record.amount,
      state_id: record.state_id
    };
  }

  function cancelEdit() {
    editingPaymentMethodId = null;
    editingData = { amount: 0, state_id: 1 };
  }

  async function saveEdit(paymentMethodId: string) {
    const record = invoiceRecordsByPaymentMethod.get(paymentMethodId);
    if (!record) return;

    try {
      await api.updateInvoiceRecord({
        id: record.id,
        amount: editingData.amount,
        state_id: editingData.state_id,
        withdrawal_date: record.withdrawal_date
      });
      toast.success('請求レコードを更新しました');

      editingPaymentMethodId = null;
      editingData = { amount: 0, state_id: 1 };

      await loadInvoiceRecords();
      if (onRefresh) onRefresh();
    } catch (error) {
      toast.error('請求レコードの更新に失敗しました');
    }
  }
</script>

<div class="layout-container">
  <h2>請求レコード管理 - {year}年{month}月</h2>
</div>

<div class="layout-container">
  {#if loading}
    <p>読み込み中...</p>
  {:else}
    <table class="style-table">
      <thead>
        <tr>
          <th>支払い方法</th>
          <th>引き落とし日</th>
          <th>金額</th>
          <th>状態</th>
          <th class="layout-center">操作</th>
        </tr>
      </thead>
      <tbody>
        {#each paymentMethods as pm (pm.id)}
          {@const record = invoiceRecordsByPaymentMethod.get(pm.id)}
          {#if record}
            <!-- 既存のInvoiceRecord -->
            <tr>
              {#if editingPaymentMethodId === pm.id}
                <!-- 編集モード -->
                <td>
                  <span>{pm.label}</span>
                </td>
                <td>
                  <span>{record.withdrawal_date}</span>
                </td>
                <td class="layout-money">
                  <input type="number" bind:value={editingData.amount} />
                </td>
                <td>
                  <select bind:value={editingData.state_id}>
                    <option value={1}>検討中</option>
                    <option value={2}>支払済</option>
                  </select>
                </td>
                <td class="layout-center">
                  <button class="style-button" onclick={() => saveEdit(pm.id)}>保存</button>
                  <button class="style-button style-button-secondary" onclick={cancelEdit}>
                    キャンセル
                  </button>
                </td>
              {:else}
                <!-- 表示モード -->
                <td>
                  <span>{pm.label}</span>
                </td>
                <td>
                  <span>{record.withdrawal_date}</span>
                </td>
                <td class="layout-money">
                  <span>¥{record.amount.toLocaleString()}</span>
                </td>
                <td>
                  <span>{record.state}</span>
                </td>
                <td class="layout-center">
                  <button class="style-button" onclick={() => startEdit(record)}>編集</button>
                  <button
                    class="style-button style-button-danger"
                    onclick={() => handleDelete(record.id)}
                  >
                    削除
                  </button>
                </td>
              {/if}
            </tr>
          {:else}
            <!-- 未作成のInvoiceRecord -->
            <tr class="unregistered-row">
              <td>
                <span>{pm.label}</span>
              </td>
              <td>
                <span>{calculateWithdrawalDate(pm)}</span>
              </td>
              <td class="layout-money">
                <span class="text-muted">-</span>
              </td>
              <td>
                <span class="text-muted">-</span>
              </td>
              <td class="layout-center">
                <button class="style-button" onclick={() => handleCreate(pm.id)}>作成</button>
              </td>
            </tr>
          {/if}
        {/each}
      </tbody>
    </table>
  {/if}
</div>

<style>
  .layout-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 24px;
  }

  .layout-container > .style-table {
    width: 100%;
    max-width: 960px;
  }

  .style-table {
    border-collapse: collapse;
    width: 100%;
  }

  .style-table th {
    background-color: var(--color-primary-bg);
    padding: 8px 16px;
  }

  .style-table td {
    padding: 8px 16px;
    height: 36px;
  }

  .style-table tbody > tr:nth-of-type(odd):not(.unregistered-row) {
    background-color: rgb(237 238 242);
  }

  .unregistered-row {
    background-color: #f8f9fa;
    font-style: italic;
  }

  .style-table input,
  .style-table select {
    width: 100%;
    padding: 4px 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
  }

  .layout-money {
    text-align: right;
  }

  .layout-center {
    text-align: center;
  }

  .text-muted {
    color: #999;
  }

  .style-button {
    background-color: var(--color-primary);
    color: white;
    border: none;
    border-radius: 8px;
    padding: 4px 12px;
    cursor: pointer;
    margin: 0 2px;
  }

  .style-button:hover {
    opacity: 0.8;
  }

  .style-button-danger {
    background-color: #dc3545;
  }

  .style-button-secondary {
    background-color: #6c757d;
  }
</style>
