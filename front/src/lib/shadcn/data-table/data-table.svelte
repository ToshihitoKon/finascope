<script lang="ts">
  // Usage
  // import DataTable from '$lib/shadcn/data-table.svelte';
  // import { type ColumnDef } from '@tanstack/table-core';
  // type TableData = {}
  // const data: TableData[] = [];
  // const columns: ColumnDef<TableData>[] = [];
  // <Datatable {data} {columns} />

  import {
    type SortingState,
    type VisibilityState,
    getCoreRowModel,
    getSortedRowModel
  } from '@tanstack/table-core';
  import { createSvelteTable, FlexRender } from '$lib/components/ui/data-table/index.js';
  import * as Table from '$lib/components/ui/table/index.js';

  let { data = [], columns = [], header = null } = $props();
  let sorting = $state<SortingState>([]);
  let columnVisibility = $state<VisibilityState>({});

  const table = createSvelteTable({
    get data() {
      return data;
    },
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: (updater) => {
      if (typeof updater === 'function') {
        sorting = updater(sorting);
      } else {
        sorting = updater;
      }
    },
    onColumnVisibilityChange: (updater) => {
      if (typeof updater === 'function') {
        columnVisibility = updater(columnVisibility);
      } else {
        columnVisibility = updater;
      }
    },
    state: {
      get sorting() {
        return sorting;
      },
      get columnVisibility() {
        return columnVisibility;
      }
    }
  });

  import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
</script>

<div>
  <div class="flex items-center py-4">
    {@render header?.()}
    <DropdownMenu.Root>
      <DropdownMenu.Trigger class="ml-auto" asChild>
        <Button variant="outline">Columns</Button>
      </DropdownMenu.Trigger>
      <DropdownMenu.Content align="end">
        {#each table.getAllColumns().filter((col) => col.getCanHide()) as column (column.id)}
          <DropdownMenu.CheckboxItem
            class="capitalize"
            bind:checked={() => column.getIsVisible(), (v) => column.toggleVisibility(!!v)}
          >
            {column.id}
          </DropdownMenu.CheckboxItem>
        {/each}
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  </div>
  <div class="rounded-md border">
    <Table.Root>
      <Table.Header>
        {#each table.getHeaderGroups() as headerGroup (headerGroup.id)}
          <Table.Row>
            {#each headerGroup.headers as header (header.id)}
              <Table.Head>
                {#if !header.isPlaceholder}
                  <FlexRender
                    content={header.column.columnDef.header}
                    context={header.getContext()}
                  />
                {/if}
              </Table.Head>
            {/each}
          </Table.Row>
        {/each}
      </Table.Header>
      <Table.Body>
        {#each table.getRowModel().rows as row (row.id)}
          <Table.Row data-state={row.getIsSelected() && 'selected'}>
            {#each row.getVisibleCells() as cell (cell.id)}
              <Table.Cell>
                <FlexRender content={cell.column.columnDef.cell} context={cell.getContext()} />
              </Table.Cell>
            {/each}
          </Table.Row>
        {:else}
          <Table.Row>
            <Table.Cell colspan={columns.length} class="h-24 text-center">No results.</Table.Cell>
          </Table.Row>
        {/each}
      </Table.Body>
    </Table.Root>
  </div>
</div>
