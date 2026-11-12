<script>
	import { enhance } from '$app/forms';
	import { resolve } from '$app/paths';

	/** @type {import('./$types').PageProps} */
	let { form } = $props();

	let submitting = $state(false);
</script>

<svelte:head>
	<title>Login | +me</title>
</svelte:head>

<main>
	<h1>Welcome to +me</h1>
	<p>Log in to your account</p>

	<form
		method="POST"
		use:enhance={() => {
			submitting = true;

			return async ({ update }) => {
				await update();
				submitting = false;
			};
		}}
	>
		<label for="email">Email</label>
		<input id="email" name="email" type="email" value={form?.email ?? ''} required />

		<label for="password">Password</label>
		<input id="password" name="password" type="password" required />

		<button type="submit" disabled={submitting}>
			{submitting ? 'Logging in...' : 'Log In'}
		</button>
	</form>

	{#if form?.message}
		<p class="error">{form.message}</p>
	{/if}

	<p>Don't have an account? <a href={resolve('/signup')}>Sign up</a></p>
</main>

<style>
	main {
		max-width: 400px;
		margin: 80px auto;
		padding: 24px;
		font-family: sans-serif;
	}

	input {
		display: block;
		width: 100%;
		padding: 10px;
		margin: 8px 0 16px;
		box-sizing: border-box;
	}

	button {
		width: 100%;
		padding: 12px;
		cursor: pointer;
	}

	.error {
		color: red;
	}
</style>
