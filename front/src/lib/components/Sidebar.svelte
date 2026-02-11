<script lang="ts">
  import { resolve } from '$app/paths';

  interface Props {
    open: boolean;
    onclose: () => void;
  }

  let { open = $bindable(), onclose }: Props = $props();

  const navItems = [
    { href: '/', label: 'Home' },
  ] as const;
</script>

{#if open}
  <div class="layout-overlay" onclick={onclose} role="presentation"></div>
{/if}

<nav class="layout-sidebar style-sidebar" class:is-open={open}>
  <div class="layout-sidebar-header">
    <button class="style-close-button" onclick={onclose} aria-label="Close menu">
      ✕
    </button>
  </div>
  <ul class="layout-nav">
    {#each navItems as item (item.href)}
      <li>
        <a
          href={resolve(item.href)}
          class="layout-nav-item style-nav-item"
          onclick={onclose}
        >
          {item.label}
        </a>
      </li>
    {/each}
  </ul>
</nav>

<style>
  .layout-sidebar {
    position: fixed;
    top: 0;
    left: 0;
    width: var(--px-sidebar-width);
    height: 100vh;
    display: flex;
    flex-direction: column;
    z-index: 100;
    transition: transform 0.2s ease;
  }

  .style-sidebar {
    background-color: var(--color-sidebar-bg);
  }

  .layout-sidebar-header {
    display: none;
    padding: 12px;
    justify-content: flex-end;
  }

  .style-close-button {
    background: none;
    border: none;
    color: var(--color-sidebar-text);
    cursor: pointer;
    padding: 4px;
    font-size: 1.2rem;
  }

  .layout-nav {
    list-style: none;
    margin: 0;
    padding: 8px 0;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .layout-nav-item {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 12px 0;
  }

  .style-nav-item {
    color: var(--color-sidebar-text);
    text-decoration: none;
    font-size: 0.75rem;
    transition: color 0.15s ease;
  }

  .style-nav-item:hover {
    color: #fff;
  }

  .layout-overlay {
    display: none;
  }

  @media (max-width: 767px) {
    .layout-sidebar {
      width: 200px;
      transform: translateX(-100%);
    }

    .layout-sidebar.is-open {
      transform: translateX(0);
    }

    .layout-sidebar-header {
      display: flex;
    }

    .layout-nav-item {
      justify-content: flex-start;
      padding: 12px 16px;
    }

    .style-nav-item {
      font-size: 0.9rem;
    }

    .layout-overlay {
      display: block;
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background: rgba(0, 0, 0, 0.4);
      z-index: 99;
    }
  }
</style>
