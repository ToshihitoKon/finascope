<script lang="ts">
  import { onMount } from 'svelte';

  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { showToast } from '$lib/toast';

  // components/*
  import SegmentControl from '$lib/components/segment-control.svelte';
  import type { SegmentControlOption } from '$lib/components/types';

  // shadcn/*
  import Combobox from '$lib/shadcn/combobox.svelte';
  import Datepicker from '$lib/shadcn/datepicker.svelte';
  import Select from '$lib/shadcn/select.svelte';
  import type { ComboboxOption, SelectOption } from '$lib/shadcn/types.d.ts';

  import { today } from '@internationalized/date';

  // api/*
  // import * as mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import * as apiconst from '$lib/api/v1/const';
  import type * as apitype from '$lib/api/v1/types.d.ts';

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
    title: '',
    recordType: '',
    state: '',
    amount: 0,
    category: '',
    paymentMethod: '',
    description: '',
    date: today('UTC')
  });

  const payloadFormatter = (): apitype.CreateRecordRequest => {
    return {
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
  const payload = $derived(() => JSON.stringify(payloadFormatter(), null, 2));

  const createRecord = async () => {
    try {
      const res = await api.createRecord(payloadFormatter());
      showToast(JSON.stringify(res), 'success');
    } catch (error) {
      console.error('Error:', error);
      showToast('Error occurred while sending data', 'error');
      return;
    }
  };
</script>

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
      onclick={() => {
        createRecord();
      }}>送信</Button
    >
  </div>

  <div class="flex flex-col gap-1">
    <Label for="preview">preview</Label>
    <textarea
      id="preview"
      class="mt-2 h-32 w-full rounded-md border border-gray-300 p-2"
      placeholder="rendered"
      >{payload()}
    </textarea>
  </div>
</div>
