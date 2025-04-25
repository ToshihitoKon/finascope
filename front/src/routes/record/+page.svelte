<script lang="ts">
  import { onMount } from 'svelte';
  import { base } from '$app/paths';

  import { Button } from '$lib/components/ui/button/index.js';

  // api/*
  // import * as mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  let records = $state<apitype.RecordsResponse>({ records: [] });

  import DataTable from '$lib/shadcn/data-table.svelte';
  import { type ColumnDef } from '@tanstack/table-core';

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
    { accessorKey: 'type', header: 'Type' },
    { accessorKey: 'title', header: 'Title' },
    { accessorKey: 'amount', header: 'Amount' },
    { accessorKey: 'state', header: 'State' },
    { accessorKey: 'description', header: 'Description' },
    { accessorKey: 'category', header: 'Category' },
    { accessorKey: 'payment_method', header: 'Payment Method' },
    { accessorKey: 'date', header: 'Date' }
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

  onMount(async () => {
    records = await api.fetchRecords();
  });
</script>

<div class="container max-w-screen-lg">
  <div class="py-4">
    <Button href={base + '/record/new'}>new</Button>
  </div>
  <DataTable data={ResponseToColumn(records)} columns={RecordColumnDef} />
</div>
