<script lang="ts">
import "../app.css";
let { children } = $props();
</script>

<nav>
	<a href="/">Home</a>
	<a href="/record">Records</a>
	<a href="/view">Views</a>
	<a href="/config">Config</a>
</nav>
<div class="container">
	{@render children()}
</div>
