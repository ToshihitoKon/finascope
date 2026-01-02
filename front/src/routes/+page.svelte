<script lang="ts">
  import {
    MainCategories,
    MonthlyExpenses,
    PaymentMethodsSummary,
    ExpenseDetails
  } from '$lib/components';
</script>

<!-- メインページ：家計簿アプリ -->
<div>
  <div>
    <MonthlyExpenses />
    <MainCategories />
    <PaymentMethodsSummary />
    <ExpenseDetails />
  </div>
</div>
