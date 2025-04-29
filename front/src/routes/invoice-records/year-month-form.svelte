<script lang="ts">
  import * as Select from '$lib/components/ui/select/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { buttonVariants } from '$lib/components/ui/button/index.js';

  let { year = $bindable(''), month = $bindable('') } = $props();
</script>

<Input
  type="number"
  bind:value={year}
  placeholder="Year"
  class="{buttonVariants({ variant: 'outline' })} w-24"
/>
<!-- Month -->
<Select.Root type="single" bind:value={month}>
  <Select.Trigger class="{buttonVariants({ variant: 'outline' })} ml-2 w-fit"
    >{month}</Select.Trigger
  >
  <Select.Content>
    {#each Array(12) as _, i}
      <Select.Item value={(i + 1).toString()}>{i + 1}</Select.Item>
    {/each}
  </Select.Content>
</Select.Root>
