<script lang="ts">
  import { MonthlyExpenses, ExpenseDetails } from '$lib/components';
</script>

<div>
  <div class="layout-summary">
    <MonthlyExpenses />
  </div>
  <div class="layout-devider style-devider"></div>
  <div class="layout-details">
    <ExpenseDetails />
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
