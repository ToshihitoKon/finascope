<script lang="ts">
  import { selectedYear, selectedMonth } from '$lib/stores/selectedMonth';

  const currentYear = new Date().getFullYear();
  const years = Array.from({ length: 7 }, (_, i) => currentYear - 3 + i);
  const months = Array.from({ length: 12 }, (_, i) => i + 1);

  function prevMonth() {
    selectedMonth.update((m) => {
      if (m === 1) {
        selectedYear.update((y) => y - 1);
        return 12;
      }
      return m - 1;
    });
  }

  function nextMonth() {
    selectedMonth.update((m) => {
      if (m === 12) {
        selectedYear.update((y) => y + 1);
        return 1;
      }
      return m + 1;
    });
  }
</script>

<div class="layout-month-selector">
  <button class="style-nav-button" onclick={prevMonth}>◀</button>
  <select class="style-select" bind:value={$selectedYear}>
    {#each years as year (year)}
      <option value={year}>{year}年</option>
    {/each}
  </select>
  <select class="style-select" bind:value={$selectedMonth}>
    {#each months as month (month)}
      <option value={month}>{month}月</option>
    {/each}
  </select>
  <button class="style-nav-button" onclick={nextMonth}>▶</button>
</div>

<style lang="scss">
  .layout-month-selector {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .style-nav-button {
    background: none;
    border: none;
    cursor: pointer;
    font-size: 1rem;
    padding: 4px 8px;
    color: var(--color-primary);
  }

  .style-nav-button:hover {
    opacity: 0.7;
  }

  .style-select {
    padding: 4px 8px;
    border: 1px solid var(--color-border);
    border-radius: 6px;
    font-size: 0.9rem;
    cursor: pointer;
    background-color: var(--color-card-bg);
    color: inherit;
  }

  @media (max-width: $bp-sp-max) {
    .layout-month-selector {
      flex-wrap: wrap;
      gap: 6px;
    }

    .style-nav-button {
      font-size: 1.25rem;
      padding: 6px 10px;
    }

    .style-select {
      // 16px 未満だと iOS Safari がフォーカス時にズームしてしまうため 1rem
      font-size: 1rem;
      padding: 6px 8px;
    }
  }
</style>
