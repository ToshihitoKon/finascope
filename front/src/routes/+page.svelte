<script lang="ts">
  import {
    MainCategories,
    // MonthlyExpenses,
    // PaymentMethodsSummary,
    // ExpenseDetails
  } from '$lib/components';
</script>

<!-- メインページ：家計簿アプリ -->
<div class="min-h-screen bg-gray-50">
  <div class="mx-auto max-w-7xl space-y-8 px-4 py-6">
    <!-- 今月の支出合計コンポーネント -->
    <div class="card p-6">
      <!-- <MonthlyExpenses /> -->
      <MainCategories />
      <!-- <PaymentMethodsSummary /> -->
    </div>

    <!-- 明細一覧コンポーネント -->
    <!-- <div class="card p-6"> -->
    <!--   <ExpenseDetails /> -->
    <!-- </div> -->
  </div>
</div>
