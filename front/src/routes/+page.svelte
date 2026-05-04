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

<div class="layout-page">
  <div class="layout-summary">
    <MonthlyExpenses {categoryAggregations} />
  </div>
  <div class="layout-section style-card">
    <ExpenseDetails />
  </div>
  <div class="layout-month-selector-wrapper">
    <MonthSelector />
  </div>
  <div class="layout-section layout-section-narrow style-card">
    <CategoryDetails />
  </div>
</div>

<style lang="scss">
  .layout-page {
    display: flex;
    flex-direction: column;
    gap: 24px;
    padding: 24px;
    // flex item の暗黙の min-width: auto を解除（子テーブルの min-width で親が押し広げられるのを防ぐ）
    min-width: 0;
  }

  .layout-month-selector-wrapper {
    display: flex;
  }

  .layout-summary {
    display: flex;
    gap: 16px;
    min-width: 0;
  }

  .layout-section {
    min-width: 0;
  }

  .layout-section-narrow {
    max-width: 680px;
  }

  .style-card {
    background-color: var(--color-card-bg);
    border: 1px solid var(--color-border);
    border-radius: 12px;
    box-shadow: var(--shadow-md);
    padding: 24px;
  }

  @media (max-width: $bp-sp-max) {
    .layout-page {
      gap: 16px;
      padding: 12px;
    }

    .style-card {
      padding: 12px;
      border-radius: 8px;
    }
  }
</style>
