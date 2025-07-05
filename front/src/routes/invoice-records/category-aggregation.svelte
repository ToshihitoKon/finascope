<script lang="ts">
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  import { buttonVariants } from '$lib/components/ui/button/index.js';

  // Props for parent component to pass data
  let {
    year,
    month,
    paymentMethodId,
    categoryId
  }: {
    year: string;
    month: string;
    paymentMethodId: string;
    categoryId: string;
  } = $props();

  // State for dialog and data
  let isDialogOpen = $state(false);
  let aggregationData = $state<apitype.InvoiceRecordsCategoryAggregation>();
  let isLoading = $state(false);

  // Fetch aggregation data
  const fetchAggregationData = async () => {
    isLoading = true;
    try {
      const response = await api.fetchInvoiceRecordsCategoryAggregation({
        year: parseInt(year),
        month: parseInt(month),
        payment_method_id: paymentMethodId,
        category_id: categoryId
      });
      aggregationData = response.aggregation;
    } catch (error) {
      console.error('Failed to fetch aggregation data:', error);
    } finally {
      isLoading = false;
    }
  };

  // Format amount for display
  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('ja-JP', {
      style: 'currency',
      currency: 'JPY'
    }).format(amount);
  };
</script>

<Dialog.Root bind:open={isDialogOpen}>
  <Dialog.Trigger>
    <Dialog.Trigger class={buttonVariants({ variant: 'outline' })} onclick={fetchAggregationData}>Open</Dialog.Trigger>
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Header>
      <Dialog.Title>カテゴリ別集計詳細</Dialog.Title>
    </Dialog.Header>

    <div>
      {#if isLoading}
        <div>読み込み中...</div>
      {:else if aggregationData}
        <div>カテゴリ: {aggregationData.category}</div>
        <div>合計金額: {formatAmount(aggregationData.total_amount)}</div>
        <div>期間: {aggregationData.begin_date} ～ {aggregationData.end_date}</div>
        <div>レコード数: {aggregationData.records.length}件</div>
        
        <div>
          {#each aggregationData.records as record}
            <div>
              {new Date(record.date).toLocaleDateString('ja-JP')} | 
              {record.title} | 
              {formatAmount(record.amount)} | 
              {record.category} | 
              {record.payment_method}
            </div>
          {/each}
        </div>
      {:else}
        <div>データがありません</div>
      {/if}
    </div>
  </Dialog.Content>
</Dialog.Root>

