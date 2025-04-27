<script lang="ts">
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { showToast } from '$lib/toast';

  // api/*
  // import * as api from '$lib/api/v1/mock';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';

  let formData = $state({
    label: ''
  });

  const payloadFormatter = (): apitype.PutCategoryRequest => {
    return {
      label: formData.label
    };
  };
  const payload = $derived(() => JSON.stringify(payloadFormatter(), null, 2));

  const putRecord = async () => {
    try {
      const res = await api.putCategory(payloadFormatter());
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
    <Label for="label">カテゴリ名</Label>
    <Input type="text" id="label" bind:value={formData.label} class="w-full" />
  </div>
  <div class="flex flex-col gap-1">
    <Button
      onclick={() => {
        putRecord();
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
