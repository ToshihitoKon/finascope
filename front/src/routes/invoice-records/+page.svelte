<script lang="ts">
  import { onMount } from 'svelte';

  // api/*
  // import * as mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  let records = $state<apitype.InvoiceRecordsResponse>({ records: [] });

  // for DataTable
  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  import { type ColumnDef } from '@tanstack/table-core';
  import { renderComponent } from '$lib/components/ui/data-table/index.js';
  import YearMonthForm from './year-month-form.svelte';
  import { Button } from '$lib/components/ui/button/index.js';

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
  onMount(async () => {
    await fetchRecordsByDate();
  });

  let year = $state(new Date().getFullYear().toString());
  let month = $state((new Date().getMonth() + 1).toString());
</script>

{#snippet header()}
  <YearMonthForm bind:year bind:month />
  <Button variant="outline" class="ml-2" onclick={() => fetchRecordsByDate()}>Apply</Button>
{/snippet}

<div class="container max-w-screen-lg">
  <DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} {header} />
</div>
