<script lang="ts">
  import { onMount } from 'svelte';
  import { Button, buttonVariants } from '$lib/components/ui/button/index.js';
  import { loginEventBus } from '$lib/firebase/index.svelte.ts';
  import * as api from '$lib/api/v1/api';
  import type * as apitype from '$lib/api/v1/types.d.ts';
  import { getLocalTimeZone, today, startOfMonth, endOfMonth } from '@internationalized/date';

  // Components
  import CategorySummaryTable from './category-summary-table.svelte';
  import RecordsDetailTable from './records-detail-table.svelte';

  // State
  let aggregations = $state<apitype.CategoryAggregationResponse>({ aggregations: [] });
  let selectedCategory = $state<apitype.CategoryAggregation | null>(null);

  // Date range handling
  import { RangeCalendar } from '$lib/components/ui/range-calendar/index.js';
  const td = today(getLocalTimeZone());
  let value = $state({
    start: startOfMonth(td),
    end: endOfMonth(td)
  });

  const setBeforeMonth = () => {
    const beforeMonth = value.start.subtract({ months: 1 });
    value = {
      start: startOfMonth(beforeMonth),
      end: endOfMonth(beforeMonth)
    };
  };

  const setNextMonth = () => {
    const nextMonth = value.start.add({ months: 1 });
    value = {
      start: startOfMonth(nextMonth),
      end: endOfMonth(nextMonth)
    };
  };

  const setThisMonth = () => {
    const td = today(getLocalTimeZone());
    value = {
      start: startOfMonth(td),
      end: endOfMonth(td)
    };
  };

  // API calls
  async function fetchCategoryAggregationData() {
    const beginDate = value.start ? value.start.toString() : undefined;
    const endDate = value.end ? value.end.toString() : undefined;
    aggregations = await api.fetchCategoryAggregation(beginDate, endDate);
    selectedCategory = null;
  }

  const handleCategorySelect = (category: apitype.CategoryAggregation) => {
    selectedCategory = category;
  };

  const handleRecordUpdate = () => {
    fetchCategoryAggregationData();
  };

  // Popover for date picker
  import CalendarIcon from '@lucide/svelte/icons/calendar';
  import { cn } from '$lib/utils.js';
  import * as Popover from '$lib/components/ui/popover/index.js';

  // Calculate total amount
  const totalAmount = $derived(aggregations.aggregations.reduce((sum, agg) => sum + agg.total_amount, 0));

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('ja-JP', {
      style: 'currency',
      currency: 'JPY'
    }).format(amount);
  };

  // Effects
  $effect(() => {
    if (value.start && value.end) {
      fetchCategoryAggregationData();
    }
  });

  onMount(() => {
    fetchCategoryAggregationData();
    const unsubscribe = loginEventBus.subscribe(() => {
      fetchCategoryAggregationData();
    });
    return () => {
      if (unsubscribe) {
        unsubscribe();
      }
    };
  });
</script>

<div class="container max-w-screen-lg">
  <h1 class="mb-6 text-2xl font-bold">カテゴリ別集計</h1>

  <!-- Date Range Selector -->
  <div class="mb-6">
    <Popover.Root>
      <Popover.Trigger
        class={cn(
          buttonVariants({
            variant: 'outline',
            class: 'w-[280px] justify-start text-left font-normal'
          }),
          !value && 'text-muted-foreground'
        )}
      >
        <CalendarIcon />
        {value.start ? value.start + ' - ' + value.end : 'Pick a date'}
      </Popover.Trigger>
      <Popover.Content class="w-auto p-0">
        <div class="flex justify-center">
          <Button variant="ghost" onclick={setBeforeMonth} class="m-2">👈️</Button>
          <Button variant="ghost" onclick={setThisMonth} class="m-2">This Month</Button>
          <Button variant="ghost" onclick={setNextMonth} class="m-2">👉️</Button>
        </div>
        <RangeCalendar bind:value class="rounded-md border" />
      </Popover.Content>
    </Popover.Root>
  </div>

  <!-- Total Amount Summary -->
  <div class="mb-6 rounded-lg border bg-muted/50 p-4">
    <div class="text-sm text-muted-foreground">期間合計</div>
    <div class="text-2xl font-bold">{formatAmount(totalAmount)}</div>
  </div>

  <!-- Category Summary Table -->
  <div class="mb-6">
    <h2 class="mb-4 text-lg font-semibold">カテゴリ別集計</h2>
    <CategorySummaryTable
      aggregations={aggregations.aggregations}
      onCategorySelect={handleCategorySelect}
    />
  </div>

  <!-- Selected Category Records Detail -->
  {#if selectedCategory}
    <div class="mb-6">
      <h2 class="mb-4 text-lg font-semibold">
        {selectedCategory.category} のレコード詳細
        <span class="text-sm text-muted-foreground">
          ({selectedCategory.record_count}件 / {formatAmount(selectedCategory.total_amount)})
        </span>
      </h2>
      <RecordsDetailTable records={selectedCategory.records} onUpdate={handleRecordUpdate} />
    </div>
  {/if}
</div>
