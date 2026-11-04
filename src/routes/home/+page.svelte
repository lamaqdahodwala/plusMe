<script>
    import { onMount } from 'svelte';

    let user = null;

    onMount(() => {
        const storedUser = localStorage.getItem('currentUser');

        if (storedUser) {
            user = JSON.parse(storedUser);
        }
    });
</script>

<svelte:head>
    <title>Home | +me</title>
</svelte:head>

<main>
    {#if user}
        <h1>Welcome, {user.name}!</h1>
        <p>You're logged into +me.</p>
    {:else}
        <h1>Welcome to +me!</h1>
    {/if}
</main>