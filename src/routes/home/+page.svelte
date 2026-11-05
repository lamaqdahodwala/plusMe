<script>
    import { goto } from '$app/navigation';
    import { supabase } from '#lib/supabase/client';

    let { data } = $props();

    let loggingOut = $state(false);

    async function handleLogout() {
        loggingOut = true;

        const { error } = await supabase.auth.signOut();

        if (error) {
            console.error(error.message);
            loggingOut = false;
            return;
        }

        await goto('/');
    }
</script>

<svelte:head>
    <title>Home | +me</title>
</svelte:head>

<main>
    <h1>Welcome to +me!</h1>

    {#if data.profile}
        <h2>Hello, {data.profile.username}!</h2>
        <p>You are successfully logged in.</p>
        <p>Email: {data.email}</p>
    {:else}
        <p>Your account is authenticated, but we couldn't load your profile.</p>
    {/if}

    <button onclick={handleLogout} disabled={loggingOut}>
        {loggingOut ? 'Logging out...' : 'Log Out'}
    </button>
</main>

<style>
    main {
        max-width: 600px;
        margin: 80px auto;
        padding: 24px;
        font-family: sans-serif;
    }

    button {
        padding: 12px 24px;
        cursor: pointer;
    }
</style>