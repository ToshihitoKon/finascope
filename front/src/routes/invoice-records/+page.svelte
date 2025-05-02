<script lang="ts">
  import { onMount } from 'svelte';

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
        withdrawal_date: new Date(record.withdrawal_date),
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
    withdrawal_date: Date;
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
      },
      sortingFn: 'datetime',
      cell: ({ cell }) => {
        let v = cell.getValue() as Date;
        return v.toLocaleDateString();
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

  import YearMonthForm from './year-month-form.svelte';
  let year = $state(new Date().getFullYear().toString());
  let month = $state((new Date().getMonth() + 1).toString());

  import { Button } from '$lib/components/ui/button/index.js';
  const fetchRecordsByDate = async () => {
    records = await api.fetchInvoiceRecords(`year=${year}&month=${month}`);
  };

  onMount(async () => {
    await fetchRecordsByDate();
  });
</script>

{#snippet header()}
  <YearMonthForm bind:year bind:month />
  <Button variant="outline" class="ml-2" onclick={() => fetchRecordsByDate()}>Apply</Button>
{/snippet}

<div class="container max-w-screen-lg">
  <DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} {header} />
</div>
