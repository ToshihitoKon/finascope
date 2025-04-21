<script lang="ts">
  import Check from 'lucide-svelte/icons/check';
  import ChevronsUpDown from 'lucide-svelte/icons/chevrons-up-down';
  import { tick } from 'svelte';
  import * as Command from '$lib/components/ui/command/index.js';
  import * as Popover from '$lib/components/ui/popover/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { cn } from '$lib/utils.js';

  import type { ComboboxOption } from './types';

  let {
    selected = $bindable<string>(''),
    options = [],
    defaultValue = 'Select'
  }: {
    selected: string;
    options: ComboboxOption[];
    defaultValue?: string;
  } = $props();

  let open = $state(false);
  let triggerRef = $state<HTMLButtonElement>(null!);
  let label = $state<string | null>(null);

  // We want to refocus the trigger button when the user selects
  // an item from the list so users can continue navigating the
  // rest of the form with the keyboard.
  function closeAndFocusTrigger() {
    open = false;
    tick().then(() => {
      triggerRef.focus();
    });
  }
</script>

<Popover.Root bind:open>
  <Popover.Trigger bind:ref={triggerRef}>
    {#snippet child({ props })}
      <Button
        variant="outline"
        class="w-[200px] justify-between"
        {...props}
        role="combobox"
        aria-expanded={open}
      >
        {label || defaultValue}
        <ChevronsUpDown class="opacity-50" />
      </Button>
    {/snippet}
  </Popover.Trigger>
  <Popover.Content class="w-[200px] p-0">
    <Command.Root>
      <Command.Input placeholder="Search ..." />
      <Command.List>
        <Command.Empty>Not found.</Command.Empty>
        <Command.Group>
          {#each options as option}
            <Command.Item
              value={option.value}
              onSelect={() => {
                selected = option.value;
                label = option.label;
                closeAndFocusTrigger();
              }}
            >
              <Check class={cn(selected !== option.value && 'text-transparent')} />
              {option.label}
            </Command.Item>
          {/each}
        </Command.Group>
      </Command.List>
    </Command.Root>
  </Popover.Content>
</Popover.Root>
