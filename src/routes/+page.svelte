<script>
	/** @type {import('./$types').PageProps} */
	let { data } = $props();
</script>

<svelte:head>
	<title>Who Am I | +me</title>
</svelte:head>

<main>
	<h1>Who am I?</h1>
  <a href="/home" class="underline">Go to Dashboard</a> <br>
  <a href="/login" class="underline">Go to Login</a>
	<pre>{JSON.stringify(data, null, 2)}</pre>
</main>

<style>
	main {
		max-width: 800px;
		margin: 40px auto;
		padding: 24px;
		font-family: sans-serif;
	}

	pre {
		padding: 16px;
		background: #f1f5f9;
		border-radius: 8px;
		overflow-x: auto;
	}
</style>
