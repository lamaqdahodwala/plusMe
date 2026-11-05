<script>
    import { supabase } from '#lib/supabase/client';

    let username = '';
    let email = '';
    let password = '';

    let errorMessage = '';
    let successMessage = '';
    let loading = false;

    async function handleSignup() {
        errorMessage = '';
        successMessage = '';
        loading = true;

        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    username
                }
            }
        });

        if (error) {
            errorMessage = error.message;
        } else if (data.session) {
            successMessage = 'Account created successfully! You can now log in.';
        } else {
            successMessage = 'Account created! Check your email to verify your account.';
        }

        loading = false;
    }
</script>

<svelte:head>
    <title>Sign Up | +me</title>
</svelte:head>

<main>
    <h1>Create your +me account</h1>

    <form onsubmit={(event) => {
        event.preventDefault();
        handleSignup();
    }}>
        <label for="username">Username</label>
        <input
            id="username"
            type="text"
            bind:value={username}
            required
        />

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
            minlength="8"
            required
        />

        <button type="submit" disabled={loading}>
            {loading ? 'Creating account...' : 'Sign Up'}
        </button>
    </form>

    {#if errorMessage}
        <p class="error">{errorMessage}</p>
    {/if}

    {#if successMessage}
        <p class="success">{successMessage}</p>
    {/if}

    <p>Already have an account? <a href="/">Log in</a></p>
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

    .success {
        color: green;
    }
</style>