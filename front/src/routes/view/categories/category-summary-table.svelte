<script lang="ts">
  import type * as apitype from '$lib/api/v1/types.d.ts';
  import * as Table from '$lib/components/ui/table/index.js';

  let {
    aggregations = [],
    onCategorySelect
  }: {
    aggregations: apitype.CategoryAggregation[];
    onCategorySelect: (category: apitype.CategoryAggregation) => void;
  } = $props();

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('ja-JP', {
      style: 'currency',
      currency: 'JPY'
    }).format(amount);
  };
</script>

<div class="rounded-md border">
  <Table.Root>
    <Table.Header>
      <Table.Row>
        <Table.Head>カテゴリ</Table.Head>
        <Table.Head class="text-center">レコード数</Table.Head>
        <Table.Head class="text-right">合計金額</Table.Head>
      </Table.Row>
    </Table.Header>
    <Table.Body>
      {#each aggregations as aggregation (aggregation.category_id)}
        <Table.Row
          class="cursor-pointer hover:bg-muted/50"
          onclick={() => onCategorySelect(aggregation)}
        >
          <Table.Cell class="font-medium">{aggregation.category}</Table.Cell>
          <Table.Cell class="text-center">{aggregation.record_count}件</Table.Cell>
          <Table.Cell class="text-right">{formatAmount(aggregation.total_amount)}</Table.Cell>
        </Table.Row>
      {:else}
        <Table.Row>
          <Table.Cell colspan={3} class="h-24 text-center">データがありません</Table.Cell>
        </Table.Row>
      {/each}
    </Table.Body>
  </Table.Root>
</div>
