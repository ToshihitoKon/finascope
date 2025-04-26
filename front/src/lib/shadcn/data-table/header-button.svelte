<script lang="ts">
  // ref. https://next.shadcn-svelte.com/docs/components/data-table#basic-table#Sorting
  // usage:
  // import DataTableHeaderButton from '$lib/shadcn/data-table/header-button.svelte';
  // {
  //   accessorKey: 'type',
  //   header: ({ column }) => {
  //     return renderComponent(DataTableHeaderButton, {
  //       header: 'Type',
  //       onclick: () => column.toggleSorting(column.getIsSorted() === 'asc')
  //     });
  //   }
  // },

  import type { ComponentProps } from 'svelte';
  import ArrowUpDown from '@lucide/svelte/icons/arrow-up-down';
  import { Button } from '$lib/components/ui/button/index.js';

  let {
    header = '',
    variant = 'ghost',
    ...restProps
  }: ComponentProps<typeof Button> & { header: string } = $props();
</script>

<Button {variant} {...restProps}>
  {header}
  <ArrowUpDown class="ml-2" />
</Button>
