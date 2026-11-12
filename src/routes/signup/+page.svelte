<script>
	import SignUpSuccess from '#lib/components/SignUpSuccess.svelte';
	import { enhance } from '$app/forms';
	import { resolve } from '$app/paths';

	/** @type {import('./$types').PageProps} */
	let { form } = $props();

	let submitting = $state(false);
</script>

<svelte:head>
	<title>Sign Up | +me</title>
</svelte:head>

<main class="grid place-items-center">
	<div>
		<h1 class="text-xl font-bold">Create your +me account</h1>

		<form
			method="POST"
      class="flex flex-col gap-3"
			use:enhance={() => {
				submitting = true;

				return async ({ update }) => {
					await update();
					submitting = false;
				};
			}}
		>
			<label for="username">Username</label>
			<input class="rounded-lg p-2" id="username" name="username" type="text" value={form?.username ?? ''} required />

			<label for="email">Email</label>
			<input class="rounded-lg p-2" id="email" name="email" type="email" value={form?.email ?? ''} required />

			<label for="password">Password</label>
			<input class="rounded-lg p-2" id="password" name="password" type="password" minlength="8" required />

			<button type="submit" disabled={submitting}>
				{submitting ? 'Creating account...' : 'Sign Up'}
			</button>
		</form>

		{#if form?.message}
      {#if form.success}

        <SignUpSuccess></SignUpSuccess>
      {/if}
		{/if}

		<p>Already have an account? <a href={resolve('/')}>Log in</a></p>
	</div>
</main>
