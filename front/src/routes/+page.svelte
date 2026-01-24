<script lang="ts">
  import { onMount } from 'svelte';
  import { MonthlyExpenses, ExpenseDetails } from '$lib/components';
  import { fetchRecords } from '$lib/api/v1/mock';
  import type { Record } from '$lib/api/v1/types';

  let records: Record[] = $state([]);

  onMount(async () => {
    const response = await fetchRecords('');
    records = response.records;
  });
</script>

<div>
  <div class="layout-summary">
    <MonthlyExpenses />
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
