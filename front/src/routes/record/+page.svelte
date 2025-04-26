<script lang="ts">
  import { onMount } from 'svelte';
  import { base } from '$app/paths';

  import { Button } from '$lib/components/ui/button/index.js';

  // api/*
  // import * as mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  let records = $state<apitype.RecordsResponse>({ records: [] });

  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  import { type ColumnDef } from '@tanstack/table-core';

  import { renderComponent } from '$lib/components/ui/data-table/index.js';

  // for RangeCalendar
  import { getLocalTimeZone, today, startOfMonth, endOfMonth } from '@internationalized/date';
  import { RangeCalendar } from '$lib/components/ui/range-calendar/index.js';
  const start = startOfMonth(today(getLocalTimeZone()));
  const end = endOfMonth(start);
  let value = $state({
    start,
    end
  });

  // for Popover
  import CalendarIcon from '@lucide/svelte/icons/calendar';
  import { cn } from '$lib/utils.js';
  import * as Popover from '$lib/components/ui/popover/index.js';
  import { buttonVariants } from '$lib/components/ui/button/index.js';
  let contentRef = $state<HTMLElement | null>(null);

  type RecordColumnStruct = {
    type: string;
    title: string;
    amount: number;
    state: string;
    description: string;
    category: string;
    payment_method: string;
    date: string;
  };

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
      }
    }
  ];

  const ResponseToColumn = (res: apitype.RecordsResponse): RecordColumnStruct[] => {
    return res.records.map((record) => {
      return {
        type: record.type,
        title: record.title,
        amount: record.amount,
        state: record.state,
        description: record.description,
        category: record.category,
        payment_method: record.payment_method,
        date: new Date(record.date).toLocaleDateString()
      };
    });
  };

  async function fetchRecordsByDateRange() {
    const params = new URLSearchParams(window.location.search);
    if (value.start) {
      params.set('begin_date', value.start.toString());
    }
    if (value.end) {
      params.set('end_date', value.end.toString());
    }
    const newUrl = `${window.location.pathname}?${params.toString()}`;
    history.pushState({}, '', newUrl);
    records = await api.fetchRecords(params.toString());
  }

  // カレンダー値が変更されたら記録を再取得する
  $effect(() => {
    if (value.start && value.end) {
      fetchRecordsByDateRange();
    }
  });

  onMount(async () => {
    const urlSearchParams = new URLSearchParams(window.location.search);
    console.log(urlSearchParams.toString());
    records = await api.fetchRecords(urlSearchParams.toString());
  });
</script>

<div class="container max-w-screen-lg">
  <div class="py-4">
    <Button href={base + '/record/new'}>new</Button>
  </div>

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
    <Popover.Content bind:ref={contentRef} class="w-auto p-0">
      <RangeCalendar bind:value class="rounded-md border" />
    </Popover.Content>
  </Popover.Root>
  <DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} />
</div>
