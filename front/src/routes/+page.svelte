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
    min-width: 0; // 子のテーブル min-width で親が押し広げられないように
  }

  .layout-month-selector-wrapper {
    display: flex;
  }

  .layout-summary {
    display: flex;
    gap: 16px;
    min-width: 0; // 同上（flex 子の暗黙 min-width: auto を解除）
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
      gap: 16px; // 24px → 16px で SP の余白を詰める
      padding: 12px; // 24px → 12px。さらに左 8px のハンバーガーボタンと干渉しない最低限
    }

    .style-card {
      padding: 12px; // 24px → 12px
      border-radius: 8px; // 12px → 8px で SP の小型カードに合わせる
    }
  }
</style>
