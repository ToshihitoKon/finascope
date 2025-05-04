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
    withdrawal_day_of_month: string;
  };

  import RowMenu from './row-menu.svelte';
  import { renderComponent } from '$lib/components/ui/data-table/index.js';

  const PaymentMethodColumnDef: ColumnDef<PaymentMethodColumnStruct>[] = [
    { accessorKey: 'label', header: '名前' },
    { accessorKey: 'withdrawal_day_of_month', header: '引き落とし日' },
    { accessorKey: 'id', header: 'ID' },
    {
      id: 'actions',
      enableHiding: false,
      cell: ({ row }) => {
        return renderComponent(RowMenu, {
          id: row.original.id,
          label: row.original.label,
          withdrawal_day_of_month: row.original.withdrawal_day_of_month
        });
      }
    }
  ];

  const fetchPaymentMethods = async () => {
    paymentMethods = await api.fetchPaymentMethods();
  };

  onMount(async () => {
    await fetchPaymentMethods();
  });
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import DialogNewPaymentMethod from './dialog-new.svelte';
  import { buttonVariants } from '$lib/components/ui/button/index.js';
</script>

{#snippet header()}
  <!-- New Record -->
  <Dialog.Root>
    <Dialog.Trigger class={buttonVariants({ variant: 'outline' })}>
      New Payment Method
    </Dialog.Trigger>
    <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
      <DialogNewPaymentMethod />
    </Dialog.Content>
  </Dialog.Root>
{/snippet}
<div class="container max-w-screen-lg">
  <DataTable data={paymentMethods.payment_methods} columns={PaymentMethodColumnDef} {header} />
</div>
