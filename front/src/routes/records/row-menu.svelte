<script lang="ts">
  import { onMount } from 'svelte';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { toast } from 'svelte-sonner';

  // api/*
  import * as _mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  import { parseDate } from '@internationalized/date';

  let {
    record,
    update
  }: {
    record: {
      id: string;
      title: string;
      record_type: string; // label
      state: string; // label
      amount: number;
      category: string; // label
      payment_method: string; // label
      description: string;
      date: string; // NOTE: ISO8601
      record_type_id: string; // number
      state_id: string; // number
      category_id: string;
      payment_method_id: string;
    };
    update: () => void;
  } = $props();

  let categories = $state<ComboboxOption[]>([]);
  let paymentMethods = $state<ComboboxOption[]>([]);

  const fetchConfigs = async () => {
    const categoriesResponse = await api.fetchCategories();
    categories = categoriesResponse.categories.map(
      (i): ComboboxOption => ({
        value: i.id,
        label: i.label
      })
    );

    const paymentMethodsResponse = await api.fetchPaymentMethods();
    paymentMethods = paymentMethodsResponse.payment_methods.map(
      (i): ComboboxOption => ({
        value: i.id,
        label: i.label
      })
    );
  };

  onMount(async () => {
    await fetchConfigs();
  });

  let formData = $state({
    title: record.title,
    recordType: record.record_type_id,
    state: record.state_id,
    amount: record.amount,
    category: record.category_id,
    paymentMethod: record.payment_method_id,
    description: record.description,
    date: parseDate(record.date)
  });
  let isValid = $derived<boolean>(
    Boolean(
      formData.title &&
        formData.recordType &&
        formData.state &&
        formData.amount &&
        formData.category &&
        formData.paymentMethod
    )
  );

  const payloadFormatter = (): apitype.UpdateRecordRequest => {
    return {
      id: record.id,
      title: formData.title,
      type_id: Number(formData.recordType),
      state_id: Number(formData.state),
      description: formData.description,
      amount: formData.amount,
      category_id: formData.category,
      payment_method_id: formData.paymentMethod,
      date: formData.date.toDate('UTC').toISOString()
    };
  };

  const updateRecord = async () => {
    try {
      const res = await api.updateRecord(payloadFormatter());
      toast.success(JSON.stringify(res));
    } catch (error) {
      console.error('Error:', error);
      toast.error('Error occurred while sending data');
      return;
    }
  };

  const deleteRecord = async () => {
    try {
      const res = await api.deleteRecord({ id: record.id });
      toast.success(JSON.stringify(res));
    } catch (error) {
      console.error('Error:', error);
      toast.error('Error occurred while sending data');
      return;
    }
  };

  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { buttonVariants } from '$lib/components/ui/button/index.js';
  import * as Popover from '$lib/components/ui/popover/index.js';
  import Ellipsis from '@lucide/svelte/icons/ellipsis';
  let editDialogOpen = $state(false);
  let deleteDialogOpen = $state(false);
  const dialogClose = () => {
    editDialogOpen = false;
    deleteDialogOpen = false;
    update();
  };

  // components/*
  import SegmentControl from '$lib/components/segment-control.svelte';
  import type { SegmentControlOption } from '$lib/components/types';
  import * as apiconst from '$lib/api/v1/const';
  import type { ComboboxOption, SelectOption } from '$lib/shadcn/types.d.ts';
  import Select from '$lib/shadcn/select.svelte';
  import Combobox from '$lib/shadcn/combobox.svelte';
  import Datepicker from '$lib/shadcn/datepicker.svelte';
  const recordTypes = apiconst.RecordTypes.map(
    (i): SegmentControlOption => ({
      label: i.label,
      value: String(i.id)
    })
  );
  const states = apiconst.States.map(
    (i): SelectOption => ({
      value: String(i.id),
      label: i.label
    })
  );
</script>

<Popover.Root>
  <Popover.Trigger><Ellipsis class="mx-2" /></Popover.Trigger>
  <Popover.Content class="w-fit">
    <div class="flex flex-col gap-1">
      <Dialog.Root bind:open={editDialogOpen}>
        <Dialog.Trigger
          class="{buttonVariants({ variant: 'ghost' })} w-full justify-stretch px-2 py-2"
        >
          <span> Edit </span>
        </Dialog.Trigger>
        <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
          <div class="mx-auto grid gap-4 sm:max-w-sm">
            <div class="flex flex-col gap-1">
              <Label>タイプ</Label>
              <SegmentControl options={recordTypes} bind:selected={formData.recordType} />
            </div>
            <div class="flex flex-col gap-1">
              <Label for="title">名前</Label>
              <Input type="text" id="name" bind:value={formData.title} class="w-full" />
            </div>
            <div class="flex flex-col gap-1">
              <Label>ステータス</Label>
              <Select options={states} bind:selected={formData.state} />
            </div>
            <div class="flex flex-col gap-1">
              <Label for="amount">金額</Label>
              <Input type="number" id="amount" bind:value={formData.amount} class="w-full" />
            </div>
            <div class="flex flex-col gap-1">
              <Label>カテゴリ</Label>
              <Combobox options={categories} bind:selected={formData.category} />
            </div>
            <div class="flex flex-col gap-1">
              <Label>支払い方法</Label>
              <Combobox options={paymentMethods} bind:selected={formData.paymentMethod} />
            </div>
            <div class="flex flex-col gap-1">
              <Label>日付</Label>
              <Datepicker bind:value={formData.date} />
            </div>
            <div class="flex flex-col gap-1">
              <Label for="memo">メモ</Label>
              <Input type="text" id="memo" bind:value={formData.description} class="w-full" />
            </div>
            <div class="flex flex-col gap-1">
              <Button
                disabled={!isValid}
                onclick={async () => {
                  await updateRecord();
                  dialogClose();
                }}>更新</Button
              >
            </div>
          </div>
        </Dialog.Content>
      </Dialog.Root>
      <Dialog.Root bind:open={deleteDialogOpen}>
        <Dialog.Trigger
          class="{buttonVariants({ variant: 'ghost' })} w-full justify-stretch px-2 py-2"
        >
          <span>Delete</span>
        </Dialog.Trigger>
        <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
          <div class="m-4 grid gap-4 sm:max-w-sm">
            <span>Delete {record.title} ?</span>
            <Button
              variant="destructive"
              onclick={async () => {
                await deleteRecord();
                dialogClose();
              }}>Delete</Button
            >
          </div>
        </Dialog.Content>
      </Dialog.Root>
    </div>
  </Popover.Content>
</Popover.Root>
