
<script>
    import { goto } from '$app/navigation';
    import { supabase } from '#lib/supabase/client';
    import EventCard from '#lib/components/EventCard.svelte';

    let { data } = $props();

    let loggingOut = $state(false);

    // Show a small preview instead of the entire event list.
    let previewEvents = $derived((data.events ?? []).slice(0, 3));

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
    <meta
        name="description"
        content="Your personalized campus event and scheduling dashboard."
    />
</svelte:head>

<main>
    <!-- Welcome section -->
    <section class="welcome-section">
        <div class="welcome-header">
            <div>
                <p class="eyebrow">YOUR CAMPUS, YOUR COMMUNITY</p>
                <h1>Hey, {data.profile?.username ?? 'there'}!</h1>
                <p class="welcome-description">
                    Ready to make the most of your campus experience?
                </p>
            </div>

            <button
                class="logout-button"
                onclick={handleLogout}
                disabled={loggingOut}
            >
                {loggingOut ? 'Logging out...' : 'Log Out'}
            </button>
        </div>
    </section>

    <!-- Main Discover feature -->
    <section class="discover-banner">
        <div class="banner-content">
            <p class="eyebrow">SOMETHING HAPPENING?</p>
            <h2>Find your next campus experience.</h2>
            <p>
                Explore campus events, meet new people, and find
                opportunities that fit your schedule.
            </p>

            <a href="/discover" class="primary-button">
                Explore Events <span aria-hidden="true">→</span>
            </a>
        </div>

        <div class="banner-icon" aria-hidden="true">
            ✨
        </div>
    </section>

    <!-- Event preview -->
    <section class="events-section">
        <div class="section-heading">
            <div>
                <p class="eyebrow">WHAT'S HAPPENING</p>
                <h2>Campus Events</h2>
                <p class="section-description">
                    A glimpse of what's happening around campus.
                </p>
            </div>

            <a href="/discover" class="text-link">
                View all events →
            </a>
        </div>

        {#if previewEvents.length > 0}
            <div class="events-grid">
                {#each previewEvents as event (event.eid)}
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
            <div class="empty-state">
                <h3>No events available yet</h3>
                <p>Check back soon for campus events and opportunities!</p>
                <a href="/discover" class="text-link">
                    Visit Discover →
                </a>
            </div>
        {/if}
    </section>

    <!-- Bottom call to action -->
    <section class="bottom-banner">
        <h2>Your campus life, all in one place.</h2>
        <p>There's always something new to discover.</p>
        <a href="/discover" class="secondary-button">
            Discover More
        </a>
    </section>
</main>

<style>
    :global(body) {
        margin: 0;
        background: #faf9fc;
        color: #292536;
        font-family: sans-serif;
    }

    main {
        max-width: 1100px;
        margin: 0 auto;
        padding: 24px;
    }


    /* Welcome */

    .welcome-section {
        margin-bottom: 36px;
    }

    .eyebrow {
        color: #8065bd;
        font-size: 11px;
        font-weight: 800;
        letter-spacing: 1.5px;
        margin-bottom: 10px;
    }

    h1 {
        font-size: clamp(30px, 5vw, 42px);
        margin: 0 0 10px;
    }

    .welcome-description {
        color: #716c7c;
        font-size: 16px;
        margin: 0;
    }

    .welcome-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
    }

    @media (max-width: 600px) {
        .welcome-header {
            align-items: flex-start;
            flex-direction: column;
        }
    }

    /* Discover banner */

    .discover-banner {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 24px;
        padding: 40px;
        margin-bottom: 56px;
        border-radius: 18px;
        background: linear-gradient(120deg, #8065bd, #a38bd0);
        color: white;
    }

    .banner-content {
        max-width: 570px;
    }

    .discover-banner .eyebrow {
        color: #eee7ff;
    }

    .discover-banner h2 {
        font-size: clamp(25px, 4vw, 34px);
        margin: 0 0 12px;
    }

    .discover-banner p:not(.eyebrow) {
        color: #f2edfa;
        line-height: 1.6;
        margin-bottom: 24px;
    }

    .primary-button {
        display: inline-block;
        padding: 12px 20px;
        border-radius: 8px;
        background: white;
        color: #7255ad;
        font-weight: 700;
        text-decoration: none;
    }

    .primary-button:hover {
        background: #f1ebfb;
    }

    .banner-icon {
        font-size: 72px;
        padding: 20px;
    }

    /* Events */

    .events-section {
        margin-bottom: 56px;
    }

    .section-heading {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        margin-bottom: 24px;
    }

    .section-heading h2 {
        margin: 0 0 8px;
        font-size: 26px;
    }

    .section-description {
        color: #716c7c;
        margin: 0;
    }

    .text-link {
        color: #8065bd;
        font-size: 14px;
        font-weight: 700;
        text-decoration: none;
        white-space: nowrap;
    }

    .text-link:hover {
        text-decoration: underline;
    }

    .events-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        gap: 20px;
    }

    .empty-state {
        padding: 36px 20px;
        text-align: center;
        background: white;
        border: 1px solid #e9e5ef;
        border-radius: 12px;
    }

    .empty-state p {
        color: #716c7c;
    }

    /* Bottom banner */

    .bottom-banner {
        padding: 32px;
        border-radius: 14px;
        background: #f0ecf7;
        text-align: center;
    }

    .bottom-banner h2 {
        margin: 0 0 8px;
        font-size: 23px;
    }

    .bottom-banner p {
        color: #716c7c;
        margin-bottom: 20px;
    }

    .secondary-button {
        display: inline-block;
        padding: 11px 20px;
        border-radius: 8px;
        background: #8065bd;
        color: white;
        text-decoration: none;
        font-weight: 700;
    }

    .secondary-button:hover {
        background: #6e54a8;
    }

    @media (max-width: 600px) {
        main {
            padding: 16px;
        }

        .top-bar {
            flex-wrap: wrap;
            margin-bottom: 32px;
        }

        nav {
            order: 3;
            width: 100%;
            justify-content: center;
            padding-top: 12px;
        }

        .discover-banner {
            padding: 28px 22px;
        }

        .banner-icon {
            display: none;
        }

        .section-heading {
            align-items: flex-start;
            flex-direction: column;
        }

        .bottom-banner {
            padding: 26px 18px;
        }
    }
</style>
