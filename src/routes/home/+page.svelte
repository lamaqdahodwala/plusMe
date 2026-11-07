
<script>
    import { goto } from '$app/navigation';
    import { supabase } from '#lib/supabase/client';
    import EventCard from '#lib/components/EventCard.svelte';

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
    <section class="welcome-section">
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
    </section>

    <section class="events-section">
        <h2>Discover Events</h2>
        <p class="section-description">
            Find something happening around campus!
        </p>

        {#if data.events?.length > 0}
            <div class="events-grid">
                {#each data.events as event (event.eid)}
                    <EventCard
                        event={{
                            name: event.name,
                            category: 'Campus Event',
                            date: new Date(event.startTime).toLocaleDateString(),
                            time: new Date(event.startTime).toLocaleTimeString([], {
                                hour: 'numeric',
                                minute: '2-digit'
                            }),
                            location: event.address,
                            description: event.description
                        }}
                    />
                {/each}
            </div>
        {:else}
            <p>No campus events available yet. Check back soon!</p>
        {/if}
    </section>
</main>

<style>
    main {
        max-width: 1100px;
        margin: 60px auto;
        padding: 24px;
        font-family: sans-serif;
    }

    .welcome-section {
        margin-bottom: 48px;
    }

    button {
        padding: 12px 24px;
        cursor: pointer;
    }

    .events-section h2 {
        margin-bottom: 8px;
    }

    .section-description {
        margin-top: 0;
        margin-bottom: 24px;
        color: #666;
    }

    .events-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        gap: 20px;
    }

    @media (max-width: 600px) {
        main {
            margin: 24px auto;
            padding: 16px;
        }

        .welcome-section {
            margin-bottom: 36px;
        }
    }
</style>
