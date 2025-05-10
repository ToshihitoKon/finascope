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
    label: ''
  });

  const payloadFormatter = (): apitype.CreateCategoryRequest => {
    return {
      label: formData.label
    };
  };

  const createRecord = async () => {
    try {
      const res = await api.createCategory(payloadFormatter());
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
    <Label for="label">カテゴリ名</Label>
    <Input type="text" id="label" bind:value={formData.label} class="w-full" />
  </div>
  <div class="flex flex-col gap-1">
    <Button
      onclick={async () => {
        await createRecord();
        close();
      }}>送信</Button
    >
  </div>
</div>
