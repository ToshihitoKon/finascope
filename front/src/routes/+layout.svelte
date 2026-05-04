<script lang="ts">
  import '../app.scss';
  import { Sidebar } from '$lib/components';
  import { Toaster } from 'svelte-sonner';

  let { children } = $props();

  let sidebarOpen = $state(false);
</script>

<div class="layout-app-wrapper style-app">
  <Sidebar bind:open={sidebarOpen} onclose={() => (sidebarOpen = false)} />

  <button
    class="layout-hamburger style-hamburger"
    onclick={() => (sidebarOpen = true)}
    aria-label="Open menu"
  >
    &#9776;
  </button>
  <main class="layout-main">
    {@render children()}
  </main>
</div>

<Toaster />

<style lang="scss">
  .layout-app-wrapper {
    display: flex;
    min-height: 100vh;
    width: 100%;
    // flex item の暗黙の min-width: auto を解除し、子コンテンツが縮まれるようにする
    min-width: 0;
    // 幅超過が起きてもビューポート外への押し出しを防ぐ最終防衛線
    overflow-x: hidden;
  }

  .layout-main {
    flex: 1;
    min-width: 0;
    max-width: var(--px-main-max-width);
    margin: 0 auto;
  }

  .layout-hamburger {
    display: none;
    position: fixed;
    top: 8px;
    left: 8px;
    z-index: 50;
  }

  .style-hamburger {
    background: var(--color-sidebar-bg);
    color: var(--color-sidebar-text);
    border: none;
    font-size: 1.5rem;
    padding: 4px 8px;
    border-radius: 4px;
    cursor: pointer;
  }

  @media (max-width: #{$px-sidebar-width + $px-main-max-width}) {
    .layout-hamburger {
      display: block;
    }
  }
</style>
