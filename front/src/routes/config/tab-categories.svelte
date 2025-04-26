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
    { accessorKey: 'label', header: '名前' },
    { accessorKey: 'id', header: 'ID' }
  ];

  const fetchCategories = async () => {
    categories = await api.fetchCategories();
  };

  onMount(async () => {
    await fetchCategories();
  });

  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import DialogNewCategory from './dialog-new-category.svelte';
  import { buttonVariants } from '$lib/components/ui/button/index.js';
</script>

{#snippet header()}
  <!-- New Record -->
  <Dialog.Root>
    <Dialog.Trigger class={buttonVariants({ variant: 'outline' })}>New Category</Dialog.Trigger>
    <Dialog.Content class="max-h-[80%] w-fit max-w-[90%] overflow-y-auto">
      <DialogNewCategory />
    </Dialog.Content>
  </Dialog.Root>
{/snippet}
<div class="container max-w-screen-lg">
  <DataTable data={categories.categories} columns={CategoryColumnDef} {header} />
</div>
