<script>
  import * as Tabs from '$lib/components/ui/tabs';
  import TabPaymentMethods from './components/payment-methods/tab-page.svelte';
  import TabCategories from './components/categories/tab-page.svelte';
</script>

<div class="container max-w-screen-lg">
  <Tabs.Root value="payment_methods">
    <div class="flex justify-center">
      <Tabs.List class="">
        <Tabs.Trigger value="payment_methods">Payment Methods</Tabs.Trigger>
        <Tabs.Trigger value="categories">Categories</Tabs.Trigger>
      </Tabs.List>
    </div>
    <Tabs.Content value="payment_methods"><TabPaymentMethods /></Tabs.Content>
    <Tabs.Content value="categories"><TabCategories /></Tabs.Content>
  </Tabs.Root>
</div>
