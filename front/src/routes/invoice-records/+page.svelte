<script lang="ts">
  import { onMount } from 'svelte';

  // api/*
  // import * as mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  let records = $state<apitype.InvoiceRecordsResponse>({ records: [] });
  let paymentMethods = $state<apitype.PaymentMethodsResponse>({ payment_methods: [] });
  let categories = $state<apitype.CategoriesResponse>({ categories: [] });

  // for DataTable
  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  import { type ColumnDef } from '@tanstack/table-core';
  import { renderComponent } from '$lib/components/ui/data-table/index.js';
  import YearMonthForm from './year-month-form.svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import * as Select from '$lib/components/ui/select/index.js';
  import { Label } from '$lib/components/ui/label/index.js';

  import RowMenu from './row-menu.svelte';

  type RecordColumnStruct = {
    id: string;
    amount: number;
    payment_method: string;
    payment_method_id: string;
    withdrawal_date: string;
    state: string;
    state_id: number;
  };

  const ResponseToColumn = (res: apitype.InvoiceRecordsResponse): RecordColumnStruct[] => {
    return res.records.map((record) => {
      // NOTE: まだ InvoiceRecord が無い場合は id が空文字になる
      // DataTable は id を要求するのでユニークな文字列を用意する
      let id = record.id;
      if (record.id == '') {
        id = '_' + record.payment_method + '_' + record.withdrawal_date;
      }
      return {
        id: id,
        payment_method: record.payment_method,
        payment_method_id: record.payment_method_id,
        amount: record.amount,
        withdrawal_date: record.withdrawal_date,
        state: record.state,
        state_id: record.state_id
      };
    });
  };

  const RecordColumnDef: ColumnDef<RecordColumnStruct>[] = [
    {
      accessorKey: 'withdrawal_date',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Withdrawal Date',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      },
      sortingFn: 'datetime',
      cell: ({ row }) => {
        return new Date(row.original.withdrawal_date).toLocaleDateString();
      }
    },
    { accessorKey: 'payment_method', header: 'Payment Method' },
    {
      accessorKey: 'amount',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Amount',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      }
    },
    {
      accessorKey: 'state',
      header: 'State',
      cell: ({ row }) => {
        if (row.original.id.startsWith('_')) {
          return 'Not reported';
        } else {
          return row.original.state;
        }
      }
    },
    {
      id: 'actions',
      enableHiding: false,
      cell: ({ row }) => {
        return renderComponent(RowMenu, {
          record: {
            id: row.original.id,
            amount: row.original.amount,
            withdrawal_date: row.original.withdrawal_date,
            payment_method_id: row.original.payment_method_id,
            state_id: String(row.original.state_id)
          },
          update: () => {
            fetchRecordsByDate();
          }
        });
      }
    }
  ];

  const fetchRecordsByDate = async () => {
    records = await api.fetchInvoiceRecords(`year=${year}&month=${month}`);
  };

  const fetchPaymentMethods = async () => {
    paymentMethods = await api.fetchPaymentMethods();
  };

  const fetchCategories = async () => {
    categories = await api.fetchCategories();
  };
  import { loginEventBus } from '$lib/firebase/index.svelte.ts';
  onMount(() => {
    fetchRecordsByDate();
    fetchPaymentMethods();
    fetchCategories();
    const unsubscribe = loginEventBus.subscribe(() => {
      fetchRecordsByDate();
      fetchPaymentMethods();
      fetchCategories();
    });
    return () => {
      if (unsubscribe) {
        unsubscribe();
      }
    };
  });

  let year = $state(new Date().getFullYear().toString());
  let month = $state((new Date().getMonth() + 1).toString());

  // Category aggregation dialog
  let categoryAggregationDialogOpen = $state(false);
  let selectedPaymentMethodId = $state('');
  let selectedCategoryId = $state('');
  let categoryAggregationData = $state<apitype.InvoiceRecordsCategoryAggregationResponse | null>(null);

  const fetchCategoryAggregation = async () => {
    if (!selectedPaymentMethodId || !selectedCategoryId) return;
    
    try {
      categoryAggregationData = await api.fetchInvoiceRecordsCategoryAggregation({
        year: parseInt(year),
        month: parseInt(month),
        payment_method_id: selectedPaymentMethodId,
        category_id: selectedCategoryId
      });
    } catch (error) {
      console.error('Error fetching category aggregation:', error);
    }
  };
</script>

{#snippet header()}
  <YearMonthForm bind:year bind:month />
  <Button variant="outline" class="ml-2" onclick={() => fetchRecordsByDate()}>Apply</Button>
  <Button variant="outline" class="ml-2" onclick={() => categoryAggregationDialogOpen = true}>Category Aggregation</Button>
{/snippet}

<div class="container max-w-screen-lg">
  <DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} {header} />
</div>

<!-- Category Aggregation Dialog -->
<Dialog.Root bind:open={categoryAggregationDialogOpen}>
  <Dialog.Content class="max-h-[80%] max-w-[90%] overflow-y-auto">
    <Dialog.Header>
      <Dialog.Title>Category Aggregation</Dialog.Title>
    </Dialog.Header>
    <div class="grid gap-4 py-4">
      <div class="grid gap-2">
        <Label for="payment-method">Payment Method</Label>
        <Select.Root>
          <Select.Trigger class="w-full">
            <Select.Value placeholder="Select payment method" />
          </Select.Trigger>
          <Select.Content>
            {#each paymentMethods.payment_methods as method}
              <Select.Item
                value={method.id}
                onSelect={() => selectedPaymentMethodId = method.id}
              >
                {method.label}
              </Select.Item>
            {/each}
          </Select.Content>
        </Select.Root>
      </div>
      
      <div class="grid gap-2">
        <Label for="category">Category</Label>
        <Select.Root>
          <Select.Trigger class="w-full">
            <Select.Value placeholder="Select category" />
          </Select.Trigger>
          <Select.Content>
            {#each categories.categories as category}
              <Select.Item
                value={category.id}
                onSelect={() => selectedCategoryId = category.id}
              >
                {category.label}
              </Select.Item>
            {/each}
          </Select.Content>
        </Select.Root>
      </div>
      
      <Button onclick={fetchCategoryAggregation} disabled={!selectedPaymentMethodId || !selectedCategoryId}>
        Aggregate
      </Button>
      
      {#if categoryAggregationData}
        <div class="mt-4">
          <h3 class="text-lg font-semibold mb-2">
            {categoryAggregationData.aggregation.category} - Total: ¥{categoryAggregationData.aggregation.total_amount.toLocaleString()}
          </h3>
          <div class="text-sm text-gray-600 mb-3">
            集計期間: {new Date(categoryAggregationData.aggregation.begin_date).toLocaleDateString()} ～ {new Date(categoryAggregationData.aggregation.end_date).toLocaleDateString()}
          </div>
          <div class="space-y-2">
            {#each categoryAggregationData.aggregation.records as record}
              <div class="border rounded p-2">
                <div class="font-medium">{record.title}</div>
                <div class="text-sm text-gray-600">
                  ¥{record.amount.toLocaleString()} - {record.date} - {record.payment_method}
                </div>
                {#if record.description}
                  <div class="text-sm text-gray-500">{record.description}</div>
                {/if}
              </div>
            {/each}
          </div>
        </div>
      {/if}
    </div>
  </Dialog.Content>
</Dialog.Root>
