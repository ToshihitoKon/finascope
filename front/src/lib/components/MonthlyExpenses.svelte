<script lang="ts">
  import type { CategoryAggregation } from '$lib/api/v1/types';

  interface Props {
    categoryAggregations?: CategoryAggregation[];
  }

  let { categoryAggregations = [] }: Props = $props();

  // 支出（record_type_id === 2）の合計金額を計算
  const totalAmount = $derived(
    categoryAggregations.reduce((sum, agg) => {
      const expenseTotal = agg.records
        .filter((record) => record.record_type_id === 2) // record_type_id 2 = 支出
        .reduce((recordSum, record) => recordSum + record.amount, 0);
      return sum + expenseTotal;
    }, 0)
  );
</script>

<div class="style-total">
  <h2 class="style-total-header">今月の支出</h2>
  <p>¥<span class="style-total-amount">{totalAmount.toLocaleString()}</span></p>
</div>

<style>
  .style-total {
    border: 2px solid var(--color-primary);
    border-radius: 16px;
    padding: 16px;
    text-align: center;
    width: fit-content;
    min-width: 360px;
  }

  .style-total-header {
    font-size: 1.25rem;
    font-weight: bold;
  }

  .style-total-amount {
    font-size: 2rem;
    font-weight: bold;
  }
</style>
