<script lang="ts">
  import { onMount } from 'svelte';
  import { Button, buttonVariants } from '$lib/components/ui/button/index.js';

  // api/*
  // import * as mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  let records = $state<apitype.RecordsResponse>({ records: [] });
  import { getLocalTimeZone, today, startOfMonth, endOfMonth } from '@internationalized/date';

  async function fetchRecordsByDateRange() {
    const params = new URLSearchParams(window.location.search);
    if (value.start) {
      params.set('begin_date', value.start.toString());
    }
    if (value.end) {
      params.set('end_date', value.end.toString());
    }
    records = await api.fetchRecords(params.toString());
  }
  const ResponseToColumn = (res: apitype.RecordsResponse): RecordColumnStruct[] => {
    return res.records.map((record) => {
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

  // for RangeCalendar
  import { RangeCalendar } from '$lib/components/ui/range-calendar/index.js';
  const td = today(getLocalTimeZone());
  let value = $state({
    start: startOfMonth(td),
    end: endOfMonth(td)
  });
  const setBeforeMonth = () => {
    const beforeMonth = value.start.subtract({ months: 1 });
    value = {
      start: startOfMonth(beforeMonth),
      end: endOfMonth(beforeMonth)
    };
  };
  const setNextMonth = () => {
    const nextMonth = value.start.add({ months: 1 });
    value = {
      start: startOfMonth(nextMonth),
      end: endOfMonth(nextMonth)
    };
  };
  const setThisMonth = () => {
    const td = today(getLocalTimeZone());
    value = {
      start: startOfMonth(td),
      end: endOfMonth(td)
    };
  };

  // for Popover
  import CalendarIcon from '@lucide/svelte/icons/calendar';
  import { cn } from '$lib/utils.js';
  import * as Popover from '$lib/components/ui/popover/index.js';

  // for DataTable
  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  import { type ColumnDef } from '@tanstack/table-core';
  import { renderComponent } from '$lib/components/ui/data-table/index.js';

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

  import RowMenu from './row-menu.svelte';
  const RecordColumnDef: ColumnDef<RecordColumnStruct>[] = [
    {
      accessorKey: 'type',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Type',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      }
    },
    { accessorKey: 'title', header: 'Title' },
    {
      accessorKey: 'amount',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Amount',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      }
    },
    { accessorKey: 'state', header: 'State' },
    { accessorKey: 'description', header: 'Description' },
    { accessorKey: 'category', header: 'Category' },
    { accessorKey: 'payment_method', header: 'Payment Method' },
    {
      accessorKey: 'date',
      header: ({ column }) => {
        return renderComponent(DataTableHeaderButton, {
          header: 'Date',
          onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
        });
      },
      cell: ({ row }) => {
        return new Date(row.original.date).toLocaleDateString();
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
          update: () => {
            fetchRecordsByDateRange();
          }
        });
      }
    }
  ];

  // for Dialog
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import DialogNewRecord from './dialog-new-record.svelte';
  let dialogOpen = $state(false);
  const dialogClose = () => {
    dialogOpen = false;
    fetchRecordsByDateRange();
  };

  $effect(() => {
    if (value.start && value.end) {
      fetchRecordsByDateRange();
    }
  });

  onMount(async () => {
    records = await api.fetchRecords('');
  });
</script>

{#snippet header()}
  <Popover.Root>
    <Popover.Trigger
      class={cn(
        buttonVariants({
          variant: 'outline',
          class: 'w-[280px] justify-start text-left font-normal'
        }),
        !value && 'text-muted-foreground'
      )}
    >
      <CalendarIcon />
      {value.start ? value.start + ' - ' + value.end : 'Pick a date'}
    </Popover.Trigger>
    <Popover.Content class="w-auto p-0">
      <div class="flex justify-center">
        <Button variant="ghost" onclick={setBeforeMonth} class="m-2">👈️</Button>
        <Button variant="ghost" onclick={setThisMonth} class="m-2">This Month</Button>
        <Button variant="ghost" onclick={setNextMonth} class="m-2">👉️</Button>
      </div>
      <RangeCalendar bind:value class="rounded-md border" />
    </Popover.Content>
  </Popover.Root>
{/snippet}

<div class="container max-w-screen-lg">
  <!-- New Record -->
  <Dialog.Root bind:open={dialogOpen}>
    <Dialog.Trigger class={buttonVariants({ variant: 'outline' })}>New Record</Dialog.Trigger>
    <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
      <DialogNewRecord close={dialogClose} />
    </Dialog.Content>
  </Dialog.Root>
  <DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} {header} />
</div>
