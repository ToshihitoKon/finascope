<script lang="ts">
  import { onMount } from 'svelte';

  // api/*
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';

  let paymentMethods = $state<apitype.PaymentMethodsResponse>({ payment_methods: [] });

  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import { type ColumnDef } from '@tanstack/table-core';

  type PaymentMethodColumnStruct = {
    id: string;
    label: string;
  };

  const PaymentMethodColumnDef: ColumnDef<PaymentMethodColumnStruct>[] = [
    { accessorKey: 'id', header: 'ID' },
    { accessorKey: 'label', header: '名前' }
  ];

  const fetchPaymentMethods = async () => {
    paymentMethods = await api.fetchPaymentMethods();
  };

  onMount(async () => {
    await fetchPaymentMethods();
  });
</script>

<div class="container max-w-screen-lg">
  <div class="flex items-center justify-between py-4">
    <h1 class="text-xl font-bold">支払い方法一覧</h1>
  </div>

  <DataTable data={paymentMethods.payment_methods} columns={PaymentMethodColumnDef} />
</div>
