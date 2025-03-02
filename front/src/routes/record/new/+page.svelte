<script lang="ts">
import { onMount } from "svelte";

import { Input } from "$lib/components/ui/input/index.js";
import { Label } from "$lib/components/ui/label/index.js";

import Combobox from "$lib/shadcn/combobox.svelte";
import Datepicker from "$lib/shadcn/datepicker.svelte";

import type { RecordType } from "types";

import * as mock from "$lib/api/mock";
import type * as apitype from "$lib/api/types.d.ts";

let recordTypes = $state<RecordType[]>([]);

onMount(async () => {
	recordTypes = await mock.fetchRecordTypesMock();
});

let formData = $state({
	selectedRecordType: "",
	status: "",
	amount: 0,
	category: "",
	description: "",
	date: "",
});

const payloadFormatter = (): apitype.NewRecord => {
	return {
		typeId: "",
		description: formData.description,
		amount: formData.amount,
		date: formData.date,
	};
};
const payload = $derived(JSON.stringify(payloadFormatter(), null));
</script>

<div class="my-4 max-w-sm">
	<Label for="">タイプ</Label>
	<Combobox options={recordTypes} bind:selected={formData.selectedRecordType} />
</div>
<div class="my-4 max-w-sm">
	<Label for="status">ステータス</Label>
	<Input type="" id="status" bind:value={formData.status} />
</div>
<div class="my-4 max-w-sm">
	<Label for="amount">金額</Label>
	<Input type="number" id="amount" bind:value={formData.amount} />
</div>
<div class="my-4 max-w-sm">
	<Label for="">カテゴリ</Label>
	<Combobox />
</div>
<div class="my-4 max-w-sm">
	<Label for="memo">メモ</Label>
	<Input type="text" id="memo" bind:value={formData.description} />
</div>
<div class="my-4 max-w-sm">
	<Label for="date">日付</Label>
	<Datepicker />
</div>

<div>
	<label for="preview">preview</label>
	<textarea
		id="preview"
		class="mt-4 h-32 w-full rounded-md border border-gray-300 p-2"
		placeholder="rendered"
		>{payload}
	</textarea>
</div>
