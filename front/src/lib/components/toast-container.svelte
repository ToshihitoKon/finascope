<script lang="ts">
  import { toasts, removeToast } from '$lib/toast';
  import { slide } from 'svelte/transition';
</script>

{#if $toasts.length > 0}
  <div class="fixed top-5 right-5 flex flex-col space-y-2 z-50">
    {#each $toasts as toast (toast.id)}
      <div
        in:slide={{ x: 200, duration: 200 }}
        out:slide={{  x: 200, duration: 200 }}
        class="max-w-sm w-full shadow-lg rounded-lg p-4 flex items-center justify-between space-x-4"
        class:bg-green-100={toast.type === 'success'}
        class:bg-red-100={toast.type === 'error'}
        class:bg-yellow-100={toast.type === 'warning'}
      >
        <div class="flex-1 text-sm">
          {toast.message}
        </div>
        <button
          class="ml-4 text-xl font-bold leading-none hover:opacity-75"
          on:click={() => removeToast(toast.id)}
        >
          &times;
        </button>
      </div>
    {/each}
  </div>
{/if}
