<script lang="ts">
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { toast } from 'svelte-sonner';

  // api/*
  // import * as api from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';

  let { close }: { close: () => void } = $props();

  let formData = $state({
    label: '',
    withdrawal_day_of_month: ''
  });

  const payloadFormatter = (): apitype.CreatePaymentMethodRequest => {
    return {
      label: formData.label,
      withdrawal_day_of_month: Number(formData.withdrawal_day_of_month)
    };
  };
  const payload = $derived(() => JSON.stringify(payloadFormatter(), null, 2));

  const createRecord = async () => {
    try {
      const res = await api.createPaymentMethod(payloadFormatter());
      toast.success(JSON.stringify(res));
    } catch (error) {
      console.error('Error:', error);
      toast.error('Error occurred while sending data');
      return;
    }
  };
</script>

<div class="mx-auto grid gap-4 sm:max-w-sm">
  <div class="flex flex-col gap-1">
    <Label for="label">支払い方法名</Label>
    <Input type="text" id="label" bind:value={formData.label} class="w-full" />
  </div>
  <div class="flex flex-col gap-1">
    <Label for="day_of_month">引き落とし日</Label>
    <Input
      type="text"
      id="day_of_month"
      bind:value={formData.withdrawal_day_of_month}
      class="w-full"
    />
  </div>
  <div class="flex flex-col gap-1">
    <Button
      onclick={async () => {
        await createRecord();
        close();
      }}
    >
      送信
    </Button>
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
