<script lang="ts">
    export const ssr = false;

	import '../app.css';
	let { children } = $props();
</script>

{@render children()}
