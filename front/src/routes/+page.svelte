<script lang="ts">
  import { toast } from 'svelte-sonner';
  import { Button } from '$lib/components/ui/button/index.js';
</script>

top nav
<Button onclick={() => toast.success('Hello world')}>success</Button>
<Button onclick={() => toast.info('Hello world')}>info</Button>
<Button onclick={() => toast.warning('Hello world')}>warn</Button>
