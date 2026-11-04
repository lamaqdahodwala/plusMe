<script>
    import { goto } from '$app/navigation';
    import { login } from '#lib/services/auth.js';

    let email = '';
    let password = '';
    let errorMessage = '';
    let loading = false;

    function handleLogin() {
        errorMessage = '';
        loading = true;

        const result = login(email, password);

        if (result.success) {
            // Save the logged-in user temporarily
            localStorage.setItem('currentUser', JSON.stringify(result.user));

            // Navigate to homepage
            goto('/home');
        } else {
            errorMessage = result.message;
        }

        loading = false;
    }
</script>

<svelte:head>
    <title>Sign In | +me</title>
</svelte:head>

<main>
    <div class="login-container">
        <h1>+me</h1>
        <p class="subtitle">Your campus life, organized.</p>

        <form onsubmit={(event) => {
            event.preventDefault();
            handleLogin();
        }}>
            <label for="email">University Email</label>
            <input
                id="email"
                type="email"
                placeholder="you@university.edu"
                bind:value={email}
                required
            />

            <label for="password">Password</label>
            <input
                id="password"
                type="password"
                placeholder="Enter your password"
                bind:value={password}
                required
            />

            {#if errorMessage}
                <p class="error">{errorMessage}</p>
            {/if}

            <button type="submit" disabled={loading}>
                {loading ? 'Signing in...' : 'Sign In'}
            </button>
        </form>
    </div>
</main>

<style>
    main {
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background: #f5f5f5;
        font-family: Arial, sans-serif;
    }

    .login-container {
        width: 100%;
        max-width: 380px;
        padding: 40px;
        background: white;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    }

    h1 {
        text-align: center;
        font-size: 40px;
        margin-bottom: 5px;
    }

    .subtitle {
        text-align: center;
        color: #777;
        margin-bottom: 30px;
    }

    label {
        display: block;
        margin-bottom: 8px;
        font-weight: bold;
    }

    input {
        box-sizing: border-box;
        width: 100%;
        padding: 12px;
        margin-bottom: 20px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 15px;
    }

    button {
        width: 100%;
        padding: 13px;
        background: #333;
        color: white;
        border: none;
        border-radius: 6px;
        font-size: 16px;
        cursor: pointer;
    }

    button:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    .error {
        color: #d32f2f;
        font-size: 14px;
        margin-bottom: 15px;
    }
</style>