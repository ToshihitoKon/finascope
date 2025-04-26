<script lang="ts">
  import { onMount } from 'svelte';

  // api/*
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';

  let categories = $state<apitype.CategoriesResponse>({ categories: [] });

  import DataTable from '$lib/shadcn/data-table/data-table.svelte';
  import { type ColumnDef } from '@tanstack/table-core';

  type CategoryColumnStruct = {
    id: string;
    label: string;
  };

  const CategoryColumnDef: ColumnDef<CategoryColumnStruct>[] = [
    { accessorKey: 'id', header: 'ID' },
    { accessorKey: 'label', header: '名前' }
  ];

  const fetchCategories = async () => {
    categories = await api.fetchCategories();
  };

  onMount(async () => {
    await fetchCategories();
  });
</script>

<div class="container max-w-screen-lg">
  <div class="flex items-center justify-between py-4">
    <h1 class="text-xl font-bold">カテゴリ一覧</h1>
  </div>

  <DataTable data={categories.categories} columns={CategoryColumnDef} />
</div>
