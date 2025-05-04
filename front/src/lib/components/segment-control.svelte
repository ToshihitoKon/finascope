<script lang="ts">
  import type { SegmentControlOption } from './types';
  let {
    selected = $bindable(''),
    options = [],
    defaultValue = ''
  }: {
    selected: string;
    options: SegmentControlOption[];
    defaultValue?: string;
  } = $props();
  if (defaultValue.length > 0) {
    selected = defaultValue;
  }
</script>

<div class="flex rounded-lg bg-gray-200 p-1">
  {#each options as option}
    <button
      class={`flex-1 rounded-lg py-1 text-center ${
        selected === option.value ? 'bg-blue-500 text-white' : 'text-gray-700'
      }`}
      onclick={() => (selected = option.value)}
    >
      {option.label}
    </button>
  {/each}
</div>
