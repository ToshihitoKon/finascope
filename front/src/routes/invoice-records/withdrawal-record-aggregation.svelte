<script lang="ts">
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';

  let {
    year,
    month,
    paymentMethodId
  }: {
    year: string;
    month: string;
    paymentMethodId: string;
  } = $props();

  let isDialogOpen = $state(false);
  let aggregationData = $state<apitype.InvoiceRecordsWithdrawalAggregation>();
  let isLoading = $state(false);

  const fetchAggregationData = async () => {
    isLoading = true;
    try {
      const response = await api.fetchInvoiceRecordsWithdrawalAggregation({
        year: parseInt(year),
        month: parseInt(month),
        payment_method_id: paymentMethodId
      });
      aggregationData = response.aggregation;
    } catch (error) {
      console.error('Failed to fetch aggregation data:', error);
    } finally {
      isLoading = false;
    }
  };

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('ja-JP', {
      style: 'currency',
      currency: 'JPY'
    }).format(amount);
  };

  const handleDialogOpen = () => {
    fetchAggregationData();
  };
</script>

<Dialog.Root bind:open={isDialogOpen}>
  <Dialog.Trigger>
    <Button variant="outline" onclick={handleDialogOpen}>詳細</Button>
  </Dialog.Trigger>
  <Dialog.Content class="max-h-[80vh] max-w-4xl overflow-y-auto">
    <Dialog.Header>
      <Dialog.Title>引き落とし対象レコード詳細</Dialog.Title>
    </Dialog.Header>

    <div class="space-y-4">
      {#if isLoading}
        <div class="py-4 text-center">読み込み中...</div>
      {:else if aggregationData}
        <div class="grid grid-cols-2 gap-4 rounded-lg bg-gray-50 p-4">
          <div>
            <div class="text-sm text-gray-600">支払い方法</div>
            <div class="font-medium">{aggregationData.payment_method}</div>
          </div>
          <div>
            <div class="text-sm text-gray-600">合計金額</div>
            <div class="text-lg font-medium">{formatAmount(aggregationData.total_amount)}</div>
          </div>
          <div>
            <div class="text-sm text-gray-600">集計期間</div>
            <div class="font-medium">
              {aggregationData.begin_date} ～ {aggregationData.end_date}
            </div>
          </div>
          <div>
            <div class="text-sm text-gray-600">レコード数</div>
            <div class="font-medium">{aggregationData.records.length}件</div>
          </div>
        </div>

        <div>
          <h4 class="mb-3 text-lg font-medium">レコード一覧</h4>
          <div class="space-y-2">
            {#each aggregationData.records as record}
              <div class="flex items-center justify-between rounded-lg border bg-white p-3">
                <div class="flex-1">
                  <div class="font-medium">{record.title}</div>
                  <div class="text-sm text-gray-600">
                    {new Date(record.date).toLocaleDateString('ja-JP')} |
                    {record.category} |
                    {record.payment_method}
                  </div>
                </div>
                <div class="text-right">
                  <div class="font-medium">{formatAmount(record.amount)}</div>
                  <div class="text-sm text-gray-600">{record.state}</div>
                </div>
              </div>
            {:else}
              <div class="text-center py-4 text-gray-500">レコードがありません</div>
            {/each}
          </div>
        </div>
      {:else}
        <div class="py-4 text-center text-gray-500">データがありません</div>
      {/if}
    </div>
  </Dialog.Content>
</Dialog.Root>
