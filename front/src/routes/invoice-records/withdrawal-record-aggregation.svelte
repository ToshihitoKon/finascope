<script lang="ts">
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  import { createRawSnippet } from 'svelte';
  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  import { type ColumnDef } from '@tanstack/table-core';
  import { renderSnippet, renderComponent } from '$lib/components/ui/data-table/index.js';

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

  type RecordColumnStruct = {
    id: string;
    title: string;
    amount: number;
    category: string;
    date: string;
    state: string;
  };

  const recordsToColumnStruct = (
    records: apitype.InvoiceRecordsWithdrawalAggregation['records']
  ): RecordColumnStruct[] => {
    return records.map((record) => ({
      id: record.id,
      title: record.title,
      amount: record.amount,
      category: record.category,
      date: record.date,
      state: record.state
    }));
  };

  const getSnippet = (cls: string) => {
    return createRawSnippet<[string | number]>((getValue) => {
      const value = getValue();
      return {
        render: () => `<div class="${cls}">${value}</div>`
      };
    });
  };

  const RecordColumnDef: ColumnDef<RecordColumnStruct>[] = [
    {
      accessorKey: 'date',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: '日付',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      },
      cell: ({ row }) => {
        const value = new Date(row.original.date).toLocaleDateString('ja-JP');
        return renderSnippet(getSnippet('min-w-20 text-sm'), value);
      }
    },
    {
      accessorKey: 'title',
      header: 'タイトル',
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-32 font-medium'), row.getValue('title'));
      }
    },
    {
      accessorKey: 'amount',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: '金額',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      },
      cell: ({ row }) => {
        const amount = row.getValue('amount') as number;
        const formatted = formatAmount(amount);
        return renderSnippet(getSnippet('min-w-20 text-right font-medium'), formatted);
      }
    },
    {
      accessorKey: 'category',
      header: 'カテゴリ',
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-24 text-sm'), row.getValue('category'));
      }
    },
    {
      accessorKey: 'state',
      header: '状態',
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-16 text-sm'), row.getValue('state'));
      }
    }
  ];

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
          <DataTable
            data={recordsToColumnStruct(aggregationData.records)}
            columns={RecordColumnDef}
          />
        </div>
      {:else}
        <div class="py-4 text-center text-gray-500">データがありません</div>
      {/if}
    </div>
  </Dialog.Content>
</Dialog.Root>
