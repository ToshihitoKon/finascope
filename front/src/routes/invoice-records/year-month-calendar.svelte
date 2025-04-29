<script lang="ts">
  import * as Select from '$lib/components/ui/select/index.js';

  const years = [...Array(5)].map((_: undefined, idx: number) => idx + 2020);

  let year = $state('');

  const triggerContent = $derived(year);
</script>

<Select.Root type="single" name="favoriteFruit" bind:year>
  <Select.Trigger class="w-[180px]">
    {triggerContent}
  </Select.Trigger>
  <Select.Content>
    <Select.Group>
      <Select.GroupHeading>Fruits</Select.GroupHeading>
      {#each years as year}
        <Select.Item value={year.toString()} label={year.toString()}>{year.toString()}</Select.Item>
      {/each}
    </Select.Group>
  </Select.Content>
</Select.Root>
