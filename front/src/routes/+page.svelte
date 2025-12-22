<script lang="ts">
  import {
    MainCategories,
    MonthlyExpenses,
    PaymentMethodsSummary,
    ExpenseDetails
  } from '$lib/components';
</script>

<!-- メインページ：家計簿アプリ -->
<div class="min-h-screen">
  <div class="mx-auto max-w-7xl space-y-8 px-4 py-6">
    <MonthlyExpenses />
    <MainCategories />
    <PaymentMethodsSummary />
    <ExpenseDetails />
  </div>
</div>
