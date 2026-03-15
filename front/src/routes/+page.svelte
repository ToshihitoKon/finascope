<script lang="ts">
  import { MonthlyExpenses, ExpenseDetails, CategoryDetails, MonthSelector } from '$lib/components';
  import { fetchCategoryAggregation } from '$lib/api/v1';
  import type { CategoryAggregation } from '$lib/api/v1/types';
  import { selectedMonthRange } from '$lib/stores/selectedMonth';

  let categoryAggregations = $state<CategoryAggregation[]>([]);

  $effect(() => {
    fetchCategoryAggregation($selectedMonthRange.beginDate, $selectedMonthRange.endDate).then(
      (res) => {
        categoryAggregations = res.aggregations;
      }
    );
  });
</script>

<div>
  <div class="layout-month-selector-wrapper">
    <MonthSelector />
  </div>
  <div class="layout-summary">
    <MonthlyExpenses {categoryAggregations} />
  </div>
  <div class="layout-devider style-devider"></div>
  <div class="layout-details">
    <ExpenseDetails />
  </div>
  <div class="layout-devider style-devider"></div>
  <div class="layout-details">
    <CategoryDetails />
  </div>
</div>

<style>
  .layout-month-selector-wrapper {
    display: flex;
    justify-content: center;
    padding: 16px 16px 0;
  }

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
