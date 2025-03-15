<script lang="ts">
	import { onMount } from 'svelte';

	import { Input } from '$lib/components/ui/input/index.js';
	import { Label } from '$lib/components/ui/label/index.js';

	// components/*
	import SegmentControl from '$lib/components/segment-control.svelte';
	import type { SegmentControlOption } from '$lib/components/types';

	// shadcn/*
	import Combobox from '$lib/shadcn/combobox.svelte';
	import Datepicker from '$lib/shadcn/datepicker.svelte';
	import Select from '$lib/shadcn/select.svelte';
	import type { ComboboxOption, SelectOption } from '$lib/shadcn/types.d.ts';

	import { today } from '@internationalized/date';

	// api/*
	import * as mock from '$lib/api/mock';
	import { States, RecordTypes } from '$lib/api/const';
	import type * as apitype from '$lib/api/types.d.ts';

	const recordTypes = RecordTypes.map(
		(i): SegmentControlOption => ({
			label: i.label,
			value: String(i.id)
		})
	);
	const states = States.map(
		(i): SelectOption => ({
			value: String(i.id),
			label: i.label
		})
	);

	let categories = $state<ComboboxOption[]>([]);

	const fetchConfigs = async () => {
		const categoriesResponse = await mock.fetchCategories();
		categories = categoriesResponse.categories.map(
			(i): ComboboxOption => ({
				value: i.id,
				label: i.label
			})
		);
	};

	onMount(async () => {
		await fetchConfigs();
	});
	let formData = $state({
		name: '',
		recordType: '',
		state: '',
		amount: 0,
		category: '',
		description: '',
		date: today('UTC')
	});

	const payloadFormatter = (): apitype.PutRecordRequest => {
		return {
			name: formData.name,
			typeId: Number(formData.recordType),
			stateId: Number(formData.state),
			description: formData.description,
			amount: formData.amount,
			categoryId: formData.category,
			date: formData.date.toDate('UTC').toISOString()
		};
	};
	const payload = $derived(() => JSON.stringify(payloadFormatter(), null, 2));
</script>

<div class="mx-auto grid gap-4 sm:max-w-sm">
	<div class="flex flex-col gap-1">
		<Label for="type">タイプ</Label>
		<SegmentControl options={recordTypes} bind:selected={formData.recordType} />
	</div>
	<div class="flex flex-col gap-1">
		<Label for="name">名前</Label>
		<Input type="text" id="name" bind:value={formData.name} class="w-full" />
	</div>
	<div class="flex flex-col gap-1">
		<Label for="state">ステータス</Label>
		<Select options={states} bind:selected={formData.state} />
	</div>
	<div class="flex flex-col gap-1">
		<Label for="amount">金額</Label>
		<Input type="number" id="amount" bind:value={formData.amount} class="w-full" />
	</div>
	<div class="flex flex-col gap-1">
		<Label for="">カテゴリ</Label>
		<Combobox options={categories} bind:selected={formData.category} />
	</div>
	<div class="flex flex-col gap-1">
		<Label for="date">日付</Label>
		<Datepicker bind:value={formData.date} />
	</div>
	<div class="flex flex-col gap-1">
		<Label for="memo">メモ</Label>
		<Input type="text" id="memo" bind:value={formData.description} class="w-full" />
	</div>

	<div class="flex flex-col gap-1">
		<label for="preview">preview</label>
		<textarea
			id="preview"
			class="mt-2 h-32 w-full rounded-md border border-gray-300 p-2"
			placeholder="rendered"
			>{payload()}
		</textarea>
	</div>
</div>
