<script lang="ts">
  import '../app.scss';
  import { Sidebar } from '$lib/components';

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

<style lang="scss">
  .layout-app-wrapper {
    display: flex;
    min-height: 100vh;
  }

  .layout-main {
    flex: 1;
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

  @media (max-width: $px-sidebar-width + $px-main-max-width) {
    .layout-hamburger {
      display: block;
    }
  }
</style>
