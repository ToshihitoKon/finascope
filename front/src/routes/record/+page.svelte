<script lang="ts">
	import { onMount } from 'svelte';
	import { base } from '$app/paths';

	import { Button } from '$lib/components/ui/button/index.js';

	// api/*
	import * as mock from '$lib/api/mock';
	import { RecordColumnDef } from '$lib/api/const';
	import type * as apitype from '$lib/api/types.d.ts';
	let records = $state<apitype.RecordsResponse>({ records: [] });

	import DataTable from '$lib/shadcn/data-table.svelte';

	onMount(async () => {
		records = await mock.fetchRecords();
	});
</script>

<div class="container max-w-screen-lg">
	<div class="py-4">
		<Button href={base + '/record/new'}>new</Button>
	</div>
	<DataTable data={records.records} columns={RecordColumnDef} />
</div>
