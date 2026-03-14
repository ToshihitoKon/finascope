<script lang="ts">
  import { onMount } from 'svelte';
  import { MonthlyExpenses, ExpenseDetails, CategoryDetails } from '$lib/components';
  import { fetchRecords, fetchCategoryAggregation } from '$lib/api/v1';
  import type { Record, CategoryAggregation } from '$lib/api/v1/types';

  let records: Record[] = $state([]);
  let categoryAggregations: CategoryAggregation[] = $state([]);

  async function loadData() {
    const [recordsResponse, aggregationResponse] = await Promise.all([
      fetchRecords(''),
      fetchCategoryAggregation('')
    ]);
    records = recordsResponse.records;
    categoryAggregations = aggregationResponse.aggregations;
  }

  onMount(loadData);
</script>

<div>
  <div class="layout-summary">
    <MonthlyExpenses {categoryAggregations} />
  </div>
  <div class="layout-devider style-devider"></div>
  <div class="layout-details">
    <ExpenseDetails {records} onRefresh={loadData} />
  </div>
  <div class="layout-devider style-devider"></div>
  <div class="layout-details">
    <CategoryDetails />
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
