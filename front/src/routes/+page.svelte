<script lang="ts">
  import { onMount } from 'svelte';
  import { MonthlyExpenses, ExpenseDetails } from '$lib/components';
  import { fetchRecords, fetchCategoryAggregation } from '$lib/api/v1/mock';
  import type { Record, CategoryAggregation } from '$lib/api/v1/types';

  let records: Record[] = $state([]);
  let categoryAggregations: CategoryAggregation[] = $state([]);

  onMount(async () => {
    const [recordsResponse, aggregationResponse] = await Promise.all([
      fetchRecords(''),
      fetchCategoryAggregation('')
    ]);
    records = recordsResponse.records;
    categoryAggregations = aggregationResponse.aggregations;
  });
</script>

<div>
  <div class="layout-summary">
    <MonthlyExpenses {categoryAggregations} />
  </div>
  <div class="layout-devider style-devider"></div>
  <div class="layout-details">
    <ExpenseDetails {records} />
  </div>
</div>

<style>
  .layout-summary {
    display: flex;
    justify-content: center;
    gap: 16px;
    padding: 16px;
  }

  .layout-devider {
    margin: 16px;
  }

  .style-devider {
    height: 0px;
    border: 1px solid var(--color-primary);
    border-radius: 1px;
  }
</style>
