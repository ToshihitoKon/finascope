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
    button: '',
    paginationArrow: '',
    ellipsis: ''
  };
</script>

<!-- ページネーション -->
<BitsPagination.Root {count} {perPage} {page}>
  {#snippet children({ pages, range })}
    <div>
      <BitsPagination.PrevButton class={classes.paginationArrow}>
        <CaretLeft />
      </BitsPagination.PrevButton>
      <div>
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
        <CaretRight />
      </BitsPagination.NextButton>
    </div>
    <p>
      Showing {range.start} - {range.end}
    </p>
  {/snippet}
</BitsPagination.Root>
