<script lang="ts">
  import { createRawSnippet } from 'svelte';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  import { type ColumnDef } from '@tanstack/table-core';
  import { renderSnippet, renderComponent } from '$lib/components/ui/data-table/index.js';
  import RowMenu from '../../records/row-menu.svelte';

  let {
    records = [],
    onUpdate
  }: {
    records: apitype.Record[];
    onUpdate: () => void;
  } = $props();

  type RecordColumnStruct = {
    id: string;
    type: string;
    title: string;
    amount: number;
    state: string;
    description: string;
    category: string;
    payment_method: string;
    date: string;
    record_type_id: number;
    state_id: number;
    category_id: string;
    payment_method_id: string;
  };

  const ResponseToColumn = (records: apitype.Record[]): RecordColumnStruct[] => {
    return records.map((record) => {
      return {
        id: record.id,
        type: record.type,
        title: record.title,
        amount: record.amount,
        state: record.state,
        description: record.description,
        category: record.category,
        payment_method: record.payment_method,
        date: record.date,
        record_type_id: record.record_type_id,
        state_id: record.state_id,
        category_id: record.category_id,
        payment_method_id: record.payment_method_id
      };
    });
  };

  const getSnippet = (cls: string) => {
    return createRawSnippet<[string]>((getValue) => {
      const value = getValue();
      return {
        render: () => `<div class=${cls}>${value}</div>`
      };
    });
  };

  const RecordColumnDef: ColumnDef<RecordColumnStruct>[] = [
    {
      accessorKey: 'type',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Type',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      },
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-16'), row.getValue('type'));
      }
    },
    {
      accessorKey: 'title',
      header: 'Title',
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-32'), row.getValue('title'));
      }
    },
    {
      accessorKey: 'amount',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Amount',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      },
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-10'), row.getValue('amount'));
      }
    },
    {
      accessorKey: 'state',
      header: 'State',
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-20'), row.getValue('state'));
      }
    },
    {
      accessorKey: 'description',
      header: 'Description',
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-60'), row.getValue('description'));
      }
    },
    {
      accessorKey: 'payment_method',
      header: 'Payment Method',
      cell: ({ row }) => {
        return renderSnippet(getSnippet('min-w-24'), row.getValue('payment_method'));
      }
    },
    {
      accessorKey: 'date',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Date',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      },
      cell: ({ row }) => {
        const value = new Date(row.original.date).toLocaleDateString();
        return renderSnippet(getSnippet('min-w-16'), value);
      }
    },
    {
      id: 'actions',
      enableHiding: false,
      cell: ({ row }) => {
        return renderComponent(RowMenu, {
          record: {
            id: row.original.id,
            title: row.original.title,
            record_type: row.original.type,
            state: row.original.state,
            amount: row.original.amount,
            category: row.original.category,
            payment_method: row.original.payment_method,
            description: row.original.description,
            date: row.original.date,
            record_type_id: row.original.record_type_id.toString(),
            state_id: row.original.state_id.toString(),
            category_id: row.original.category_id.toString(),
            payment_method_id: row.original.payment_method_id.toString()
          },
          update: onUpdate
        });
      }
    }
  ];
</script>

<DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} />
