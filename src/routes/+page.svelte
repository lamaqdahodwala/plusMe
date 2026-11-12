<script>
    import { goto } from '$app/navigation';
    import { supabase } from '#lib/supabase/client';

    let email = '';
    let password = '';
    let errorMessage = '';
    let loading = false;

    async function handleLogin() {
        errorMessage = '';
        loading = true;

        const { error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) {
            errorMessage = error.message;
        } else {
            await goto('/home');
        }

        loading = false;
    }
</script>

<svelte:head>
    <title>Login | +me</title>
</svelte:head>

<main>
    <h1>Welcome to +me</h1>
    <p>Log in to your account</p>

    <form onsubmit={(event) => {
        event.preventDefault();
        handleLogin();
    }}>
        <label for="email">Email</label>
        <input
            id="email"
            type="email"
            bind:value={email}
            required
        />

        <label for="password">Password</label>
        <input
            id="password"
            type="password"
            bind:value={password}
            required
        />

        <button type="submit" disabled={loading}>
            {loading ? 'Logging in...' : 'Log In'}
        </button>
    </form>

    {#if errorMessage}
        <p class="error">{errorMessage}</p>
    {/if}

    <p>Don't have an account? <a href="/signup">Sign up</a></p>
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
