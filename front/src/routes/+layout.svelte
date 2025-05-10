<script lang="ts">
  import '../app.css';
  import Menu from 'lucide-svelte/icons/menu';
  import X from 'lucide-svelte/icons/x';
  import { base } from '$app/paths';
  import { Toaster } from '$lib/components/ui/sonner/index.js';

  let { children } = $props();
  let isOpen = $state(false);

  import { Button } from '$lib/components/ui/button/index.js';
  import { signInWithGoogle, loggedInUserInformation } from '$lib/firebase/index.svelte.ts';

  const loginHandler = async () => {
    await signInWithGoogle();
  };

  let hideLoginButton = $state(false);
  $effect(() => {
    hideLoginButton = loggedInUserInformation.isLoggedIn;
  });
</script>

<nav class="bg-card text-foreground shadow-md">
  <div class="item-center container mx-auto flex justify-between p-4">
    <a href="{base}/" class="text-x1 font-bold">Finascope</a>
    <div class="hidden space-x-6 md:flex">
      <a href="{base}/records" class="hover:text-primary">Records</a>
      <a href="{base}/invoice-records" class="hover:text-primary">Invoice Records</a>
      <a href="{base}/view" class="hover:text-primary">Views</a>
      <a href="{base}/config" class="hover:text-primary">Config</a>
      {#if !hideLoginButton}
        <Button onclick={loginHandler} variant="outline" class="h-8">Login</Button>
      {/if}
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
        <a href="{base}/records" class="hover:text-primary" onclick={() => (isOpen = false)}>
          Records
        </a>
        <a
          href="{base}/invoice-records"
          class="hover:text-primary"
          onclick={() => (isOpen = false)}
        >
          Invoice Records
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
<Toaster
  richColors
  closeButton
  toastOptions={{
    classes: {
      // Patch: fix bug https://github.com/wobsoriano/svelte-sonner/issues/122#issuecomment-2563566656
      // toast: "group toast group-[.toaster]:bg-background group-[.toaster]:text-foreground group-[.toaster]:border-border group-[.toaster]:shadow-lg",
      toast: 'group toast group-[.toaster]:shadow-lg',
      description: 'group-[.toast]:text-muted-foreground',
      actionButton: 'group-[.toast]:bg-primary group-[.toast]:text-primary-foreground',
      cancelButton: 'group-[.toast]:bg-muted group-[.toast]:text-muted-foreground'
    }
  }}
/>
<div class="container mx-auto px-4 py-6">
  {@render children()}
</div>
