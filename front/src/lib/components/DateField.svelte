<script lang="ts">
  import { DateField, type WithoutChildrenOrChild } from 'bits-ui';

  let {
    value = $bindable(),
    placeholder = $bindable(),
    labelText,
    ...restProps
  }: WithoutChildrenOrChild<DateField.RootProps> & {
    labelText?: string;
  } = $props();
</script>

<DateField.Root bind:value bind:placeholder {...restProps}>
  <div>
    {#if labelText}
      <DateField.Label>{labelText}</DateField.Label>
    {/if}
    <DateField.Input>
      {#snippet children({ segments })}
        {#each segments as { part, value }, index (index)}
          <DateField.Segment {part}>
            {value}
          </DateField.Segment>
        {/each}
      {/snippet}
    </DateField.Input>
  </div>
</DateField.Root>
