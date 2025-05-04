<script lang="ts">
  import { toasts, removeToast } from '$lib/toast';
  import { slide } from 'svelte/transition';
</script>

{#if $toasts.length > 0}
  <div class="fixed right-5 top-5 z-50 flex flex-col space-y-2">
    {#each $toasts as toast (toast.id)}
      <div
        in:slide={{ duration: 200 }}
        out:slide={{ duration: 200 }}
        class="flex w-full max-w-sm items-center justify-between space-x-4 rounded-lg p-4 shadow-lg"
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
