<script lang="ts">
  import { onMount } from 'svelte';
  import { buttonVariants } from '$lib/components/ui/button/index.js';

  // api/*
  // import * as mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  let records = $state<apitype.InvoiceRecordsResponse>({ records: [] });

  const ResponseToColumn = (res: apitype.InvoiceRecordsResponse): RecordColumnStruct[] => {
    return res.records.map((record) => {
      return {
        payment_method: record.payment_method,
        amount: record.amount,
        withdrawal_date: new Date(record.withdrawal_date).toLocaleDateString(),
        state: record.state
      };
    });
  };

  // for DataTable
  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  import { type ColumnDef } from '@tanstack/table-core';
  import { renderComponent } from '$lib/components/ui/data-table/index.js';

  type RecordColumnStruct = {
    amount: number;
    payment_method: string;
    withdrawal_date: string;
    state: string;
  };

  const RecordColumnDef: ColumnDef<RecordColumnStruct>[] = [
    {
      accessorKey: 'withdrawal_date',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Withdrawal Date',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
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
    { accessorKey: 'state', header: 'State' }
  ];

  // for Dialog
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import DialogNewRecord from './dialog-new-invoice-record.svelte';

  // base
  // $effect(() => {
  //   if (value.start && value.end) {
  //     fetchRecordsByDateRange();
  //   }
  // });

  onMount(async () => {
    records = await api.fetchInvoiceRecords('year=2024&month=3');
  });
</script>

{#snippet header()}{/snippet}

<div class="container max-w-screen-lg">
  <!-- New Record -->
  <Dialog.Root>
    <Dialog.Trigger class={buttonVariants({ variant: 'outline' })}>New Record</Dialog.Trigger>
    <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
      <DialogNewRecord />
    </Dialog.Content>
  </Dialog.Root>
  <DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} {header} />
</div>
