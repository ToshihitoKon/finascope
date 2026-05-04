<script lang="ts">
  import { DateField, type WithoutChildrenOrChild } from 'bits-ui';

  let {
    value = $bindable(),
    placeholder = $bindable(),
    labelText,
    locale = 'ja-JP',
    ...restProps
  }: WithoutChildrenOrChild<DateField.RootProps> & {
    labelText?: string;
  } = $props();
</script>

<DateField.Root bind:value bind:placeholder {locale} {...restProps}>
  <div>
    {#if labelText}
      <DateField.Label>{labelText}</DateField.Label>
    {/if}
    <div class="layout-date-input">
      <DateField.Input>
        {#snippet children({ segments })}
          {#each segments as { part, value }, index (index)}
            <span class="layout-segment">
              <DateField.Segment {part}>
                {part === 'literal' ? '-' : value}
              </DateField.Segment>
            </span>
          {/each}
        {/snippet}
      </DateField.Input>
    </div>
  </div>
</DateField.Root>

<style>
  .layout-segment {
    padding: 0px 2px;
  }

  .layout-date-input {
    display: inline-flex;
    align-items: center;
    height: 28px;
    padding: 4px 8px;
    border-bottom: 1px solid transparent;
    box-sizing: border-box;
    font-size: inherit;
    font-family: inherit;
    background-color: transparent;
    transition: border-color 0.15s, background-color 0.15s;
    cursor: text;
  }

  .layout-date-input :global([data-segment]) {
    font-size: inherit;
    font-family: inherit;
    outline: none;
  }

  .layout-date-input:focus-within {
    border-bottom-color: var(--color-primary);
    background-color: rgba(255, 255, 255, 0.6);
  }
</style>
