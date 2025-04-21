<script lang="ts">
  import '../app.css';
  import { Menu, X } from 'lucide-svelte'; // アイコン用
  import { base } from '$app/paths';
  let { children } = $props();
  let isOpen = $state(false);
</script>

<nav class="bg-card text-foreground shadow-md">
  <div class="item-center container mx-auto flex justify-between p-4">
    <a href="{base}/" class="text-x1 font-bold">Finascope</a>
    <div class="hidden space-x-6 md:flex">
      <a href="{base}/record" class="hover:text-primary">Records</a>
      <a href="{base}/view" class="hover:text-primary">Views</a>
      <a href="{base}/config" class="hover:text-primary">Config</a>
    </div>
    <button class="md:hidden" onclick={() => (isOpen = !isOpen)}>
      {#if isOpen}
        <X class="h-6 w-6" />
      {:else}
        <Menu class="h-6 w-6" />
      {/if}
    </button>
  </div>

  <!-- モバイル用ドロップダウンメニュー -->
  {#if isOpen}
    <div class="animate-fade-in border-t border-border bg-card md:hidden">
      <div class="container mx-auto flex flex-col space-y-4 p-4">
        <a href="{base}/" class="hover:text-primary" onclick={() => (isOpen = false)}> Home </a>
        <a href="{base}/record" class="hover:text-primary" onclick={() => (isOpen = false)}>
          Records
        </a>
        <a href="{base}/view" class="hover:text-primary" onclick={() => (isOpen = false)}>
          Views
        </a>
        <a href="{base}/config" class="hover:text-primary" onclick={() => (isOpen = false)}>
          Config
        </a>
      </div>
    </div>
  {/if}
</nav>
<div class="container mx-auto px-4 py-6">
  {@render children()}
</div>
