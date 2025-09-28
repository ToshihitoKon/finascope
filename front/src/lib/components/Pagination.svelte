<script lang="ts">
  import { Pagination as BitsPagination } from 'bits-ui';
  import CaretLeft from 'phosphor-svelte/lib/CaretLeft';
  import CaretRight from 'phosphor-svelte/lib/CaretRight';

  interface Props {
    count: number; // All Items Count
    page?: number; // Current page. Default: 1
    perPage?: number; // Default: 10
  }

  let { count, page = $bindable(1), perPage = 10 }: Props = $props();
  const classes = {
    button:
      'inline-flex items-center justify-center size-10 rounded-[9px] text-[15px] data-[selected]:bg-[#d55a6a] data-[selected]:text-white \
      hover:bg-[#d55a6a] hover:text-white disabled:text-muted-foreground',
    paginationArrow:
      'size-10 rounded-[9px] inline-flex items-center justify-center bg-transparent disabled:cursor-not-allowed hover:bg-[#d55a6a] \
      hover:text-white disabled:text-muted-foreground  disabled:hover:bg-transparent mx-[10px]',
    ellipsis: 'inline-flex items-center justify-center size-6 text-[15px]'
  };
</script>

<!-- ページネーション -->
<BitsPagination.Root {count} {perPage} {page}>
  {#snippet children({ pages, range })}
    <div class="my-2 flex items-center">
      <BitsPagination.PrevButton class={classes.paginationArrow}>
        <CaretLeft class="size-6" />
      </BitsPagination.PrevButton>
      <div class="flex items-center gap-2.5">
        {#each pages as page (page.key)}
          {#if page.type === 'ellipsis'}
            <div class={classes.ellipsis}>...</div>
          {:else}
            <BitsPagination.Page {page} class={classes.button}>
              {page.value}
            </BitsPagination.Page>
          {/if}
        {/each}
      </div>
      <BitsPagination.NextButton class={classes.paginationArrow}>
        <CaretRight class="size-6" />
      </BitsPagination.NextButton>
    </div>
    <p class="text-muted-foreground text-center text-sm">
      Showing {range.start} - {range.end}
    </p>
  {/snippet}
</BitsPagination.Root>
