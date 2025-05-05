<script lang="ts">
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { showToast } from '$lib/toast';

  // api/*
  import * as _mock from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';

  let {
    id,
    label,
    withdrawal_day_of_month
  }: { id: string; label: string; withdrawal_day_of_month: string } = $props();
  let formData = $state({
    label: label,
    withdrawal_day_of_month: withdrawal_day_of_month
  });

  const payloadFormatter = (): apitype.UpdatePaymentMethodRequest => {
    return {
      id: id,
      label: formData.label,
      withdrawal_day_of_month: Number(formData.withdrawal_day_of_month)
    };
  };

  const updateRecord = async () => {
    try {
      const res = await api.updatePaymentMethod(payloadFormatter());
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
              <Label for="label">支払い方法名</Label>
              <Input type="text" id="label" bind:value={formData.label} class="w-full" />
            </div>
            <div class="flex flex-col gap-1">
              <Label for="withdrawable-day">引き落とし日</Label>
              <Input
                type="number"
                id="withdrawable-day"
                bind:value={formData.withdrawal_day_of_month}
                class="w-full"
              />
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
    </div>
  </Popover.Content>
</Popover.Root>
