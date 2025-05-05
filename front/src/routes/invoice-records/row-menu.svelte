<script lang="ts">
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { showToast } from '$lib/toast';

  // api/*
  import * as _mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  import { parseDate } from '@internationalized/date';

  let {
    record
  }: {
    record: {
      id: string;
      amount: number;
      withdrawal_date: string; // NOTE: ISO8601
      payment_method_id: string;
      state_id: string; // number
    };
  } = $props();

  let formData = $state({
    state: record.state_id,
    amount: record.amount,
    withdrawal_date: parseDate(record.withdrawal_date)
  });

  const createPayloadFormatter = (): apitype.CreateInvoiceRecordRequest => {
    return {
      amount: formData.amount,
      state_id: Number(formData.state),
      payment_method_id: record.payment_method_id,
      withdrawal_date: formData.withdrawal_date.toDate('UTC').toISOString()
    };
  };
  const updatePayloadFormatter = (): apitype.UpdateInvoiceRecordRequest => {
    return {
      id: record.id,
      amount: formData.amount,
      state_id: Number(formData.state),
      withdrawal_date: formData.withdrawal_date.toDate('UTC').toISOString()
    };
  };

  const updateRecord = async () => {
    try {
      let res;
      if (record.id == '' || record.id.startsWith('_')) {
        const payload = createPayloadFormatter();
        res = await api.createInvoiceRecord(payload);
      } else {
        const payload = updatePayloadFormatter();
        res = await api.updateInvoiceRecord(payload);
      }
      showToast(JSON.stringify(res), 'success');
    } catch (error) {
      console.error('Error:', error);
      showToast('Error occurred while sending data', 'error');
      return;
    }
  };

  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { buttonVariants } from '$lib/components/ui/button/index.js';
  import * as Popover from '$lib/components/ui/popover/index.js';
  import Ellipsis from '@lucide/svelte/icons/ellipsis';

  // components/*
  import * as apiconst from '$lib/api/v1/const';
  import type { SelectOption } from '$lib/shadcn/types.d.ts';
  import Select from '$lib/shadcn/select.svelte';
  import Datepicker from '$lib/shadcn/datepicker.svelte';
  const states = apiconst.InvoiceRecordStates.map(
    (i): SelectOption => ({
      value: String(i.id),
      label: i.label
    })
  );

  const deleteRecord = async () => {
    try {
      const res = await api.deleteInvoiceRecord({ id: record.id });
      showToast(JSON.stringify(res), 'success');
    } catch (error) {
      console.error('Error:', error);
      showToast('Error occurred while sending data', 'error');
      return;
    }
  };
</script>

<Popover.Root>
  <Popover.Trigger><Ellipsis class="mx-2" /></Popover.Trigger>
  <Popover.Content class="w-fit">
    <div class="flex flex-col gap-1">
      <Dialog.Root>
        <Dialog.Trigger
          class="{buttonVariants({ variant: 'ghost' })} w-full justify-stretch px-2 py-2"
        >
          <span> Edit </span>
        </Dialog.Trigger>
        <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
          <div class="mx-auto grid gap-4 sm:max-w-sm">
            <div class="flex flex-col gap-1">
              <Label>ステータス</Label>
              <Select options={states} bind:selected={formData.state} />
            </div>
            <div class="flex flex-col gap-1">
              <Label for="amount">金額</Label>
              <Input type="number" id="amount" bind:value={formData.amount} class="w-full" />
            </div>
            <div class="flex flex-col gap-1">
              <Label>支払日</Label>
              <Datepicker bind:value={formData.withdrawal_date} />
            </div>
            <div class="flex flex-col gap-1">
              <Button
                onclick={() => {
                  updateRecord();
                }}>更新</Button
              >
            </div>
          </div>
        </Dialog.Content>
      </Dialog.Root>
      <Dialog.Root>
        <Dialog.Trigger
          class="{buttonVariants({ variant: 'ghost' })} w-full justify-stretch px-2 py-2"
        >
          <span>Delete</span>
        </Dialog.Trigger>
        <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
          <div class="m-4 grid gap-4 sm:max-w-sm">
            <!-- あまりにもなのでなんか良いタイトルが必要 -->
            <span>Delete {record.withdrawal_date} ?</span>
            <Button
              variant="destructive"
              onclick={() => {
                deleteRecord();
              }}>Delete</Button
            >
          </div>
        </Dialog.Content>
      </Dialog.Root>
    </div>
  </Popover.Content>
</Popover.Root>
