<script lang="ts">
	import * as Select from '$lib/components/ui/select/index.js';

	let {
		options = [],
		selected = $bindable<string>('')
	}: {
		options: { value: string; label: string }[];
		selected: string;
	} = $props();
	const triggerContent = $derived(options.find((f) => f.value === selected)?.label ?? 'Select');
</script>

<Select.Root type="single" bind:value={selected}>
	<Select.Trigger class="w-[180px]">
		{triggerContent}
	</Select.Trigger>
	<Select.Content>
		<Select.Group>
			{#each options as option}
				<Select.Item value={option.value} label={option.label}>{option.label}</Select.Item>
			{/each}
		</Select.Group>
	</Select.Content>
</Select.Root>
