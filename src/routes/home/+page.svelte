<script>
    import { goto } from '$app/navigation';
    import { supabase } from '#lib/supabase/client';
    import EventCard from '#lib/components/EventCard.svelte';

    let { data } = $props();

    let loggingOut = $state(false);

<<<<<<< HEAD
    // Show a small preview instead of the entire event list.
    let previewEvents = $derived((data.events ?? []).slice(0, 3));
=======
    let username = $derived(data?.profile?.username || 'Student');
    let initials = $derived(username.slice(0, 2).toUpperCase());
>>>>>>> 0da2b11 (h)

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

<<<<<<< HEAD
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
=======
<!-- Top Navigation Bar -->
<header class="top-bar">
    <a href="/home" class="brand-logo">
        <span class="plus">+</span>me
        <span class="brand-tag">RU</span>
    </a>

    <!-- Profile & Logout Action Area -->
    <div class="profile-container">
        {#if data?.profile?.profile_pic}
            <img src={data.profile.profile_pic} alt="Profile" class="avatar-img" />
        {:else}
            <div class="avatar">{initials}</div>
        {/if}

        <button class="logout-btn" onclick={handleLogout} disabled={loggingOut}>
            {loggingOut ? 'Logging out...' : 'Log Out'}
        </button>
    </div>
</header>

<!-- Personalized Welcome Hero Section -->
<section class="welcome-header">
    <div class="welcome-container">
        <span class="greeting-badge">👋 Welcome back</span>
        <h1 class="welcome-title">Hey, {username}! Ready to explore Rutgers?</h1>
        <p class="welcome-description">
            Discover campus events tailored for you. Browse upcoming <span class="highlight">academic workshops and social gatherings</span>, instant-RSVP to secure your spot, and sync events directly to your personal calendar so you never miss out.
        </p>
    </div>
</section>

<!-- Events Grid Content -->
<main class="content-wrapper">
    <section class="events-section">
        <h2>Discover Events</h2>
        <p class="section-description">
            Find something happening around campus!
        </p>
>>>>>>> 0da2b11 (h)

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
<<<<<<< HEAD
            <div class="empty-state">
                <h3>No events available yet</h3>
                <p>Check back soon for campus events and opportunities!</p>
                <a href="/discover" class="text-link">
                    Visit Discover →
                </a>
            </div>
=======
            <p class="empty-state">No campus events available yet. Check back soon!</p>
>>>>>>> 0da2b11 (h)
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
<<<<<<< HEAD
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
=======
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background-color: #F8F9FA;
        color: #1C1C1E;
    }

    /* Top Bar Header Layout */
    .top-bar {
        background-color: #FFFFFF;
        border-bottom: 1px solid #E5E7EB;
        padding: 0 32px;
        height: 64px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .brand-logo {
        display: flex;
        align-items: center;
        text-decoration: none;
        font-weight: 800;
        font-size: 1.5rem;
        letter-spacing: -0.5px;
        color: #1C1C1E;
    }

    .brand-logo .plus {
        color: #CC0033; /* Rutgers Scarlet */
    }

    .brand-tag {
        font-size: 0.65rem;
        font-weight: 700;
        text-transform: uppercase;
        background: rgba(204, 0, 51, 0.08);
        color: #CC0033;
        padding: 2px 6px;
        border-radius: 4px;
        margin-left: 8px;
    }

    /* Avatar & Logout */
    .profile-container {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .avatar {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background-color: #CC0033;
        color: #FFFFFF;
        font-weight: 700;
        font-size: 0.9rem;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .avatar-img {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        object-fit: cover;
    }

    .logout-btn {
        padding: 8px 16px;
        font-size: 0.85rem;
        font-weight: 600;
        color: #6B7280;
        background: transparent;
        border: 1px solid #E5E7EB;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .logout-btn:hover {
        color: #CC0033;
        border-color: #CC0033;
        background-color: rgba(204, 0, 51, 0.04);
    }

    /* Welcome Banner */
    .welcome-header {
        background-color: #FFFFFF;
        border-bottom: 1px solid #E5E7EB;
        padding: 48px 32px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .welcome-container {
        max-width: 1100px;
        margin: 0 auto;
    }

    .greeting-badge {
        display: inline-block;
        font-size: 0.85rem;
        font-weight: 600;
        color: #CC0033;
        background-color: rgba(204, 0, 51, 0.08);
        padding: 4px 12px;
        border-radius: 99px;
        margin-bottom: 12px;
    }

    .welcome-title {
        font-size: 2.25rem;
        font-weight: 800;
        letter-spacing: -0.02em;
        color: #1C1C1E;
        margin-bottom: 12px;
    }

    .welcome-description {
        font-size: 1.05rem;
        line-height: 1.6;
        color: #6B7280;
        max-width: 720px;
    }

    .highlight {
        color: #1C1C1E;
        font-weight: 600;
    }

    /* Main Page Content Wrapper */
    .content-wrapper {
        max-width: 1100px;
        margin: 40px auto;
        padding: 0 32px;
    }

    .events-section h2 {
        font-size: 1.5rem;
        font-weight: 700;
        margin-bottom: 4px;
    }

    .section-description {
        margin-top: 0;
        margin-bottom: 24px;
        color: #6B7280;
>>>>>>> 0da2b11 (h)
    }

    .events-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 24px;
    }

    .empty-state {
        color: #6B7280;
        font-style: italic;
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
<<<<<<< HEAD
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
=======
        .top-bar, .welcome-header, .content-wrapper {
            padding-left: 16px;
            padding-right: 16px;
        }

        .welcome-header {
            padding-top: 32px;
            padding-bottom: 32px;
        }

        .welcome-title {
            font-size: 1.75rem;
>>>>>>> 0da2b11 (h)
        }
    }
</style>

