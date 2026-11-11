
<script lang="ts">
    type EventTagRelationship = {
        Tag: {
            name: string;
        } | null;
    };

    type DatabaseEvent = {
        eid: string;
        name: string;
        description: string | null;
        address: string | null;
        startTime: string;
        duration: number;
        link: string | null;
        EventTag: EventTagRelationship[] | null;
    };

    const categories = [
        'All',
        'Academic',
        'Social',
        'Career',
        'Sports'
    ];

    let { data }: { data: { events: DatabaseEvent[] } } = $props();

    let searchQuery = $state('');
    let selectedCategory = $state('All');

    let events = $derived(
        data.events.map((event) => {
            const tags = event.EventTag
                ?.map((relationship) => relationship.Tag?.name)
                .filter((tag): tag is string => typeof tag === 'string') ?? [];

            const validCategories = [
                'Academic',
                'Social',
                'Career',
                'Sports'
            ];

            const category = tags.find((tag) =>
                validCategories.some(
                    (valid) => valid.toLowerCase() === tag.toLowerCase()
                )
            ) ?? 'Campus Event';

            return {
                id: event.eid,
                name: event.name,
                organization: 'Campus Organization',
                location: event.address ?? 'Location not specified',
                date: new Date(event.startTime).toLocaleDateString('en-US', {
                    month: 'long',
                    day: 'numeric'
                }),
                time: new Date(event.startTime).toLocaleTimeString([], {
                    hour: 'numeric',
                    minute: '2-digit'
                }),
                category,
                description: event.description ?? 'No description available.'
            };
        })
    );

    let filteredEvents = $derived(
        events.filter((event) => {
            const query = searchQuery.toLowerCase().trim();

            const matchesSearch =
                event.name.toLowerCase().includes(query) ||
                event.organization.toLowerCase().includes(query) ||
                event.location.toLowerCase().includes(query) ||
                event.description.toLowerCase().includes(query);

            const matchesCategory =
                selectedCategory === 'All' ||
                event.category === selectedCategory;

            return matchesSearch && matchesCategory;
        })
    );

    function resetFilters() {
        searchQuery = '';
        selectedCategory = 'All';
    }
</script>

<svelte:head>
    <title>Discover Events | plusMe</title>
</svelte:head>

<main class="page-container">

    <header class="page-header">
        <div>
            <p class="eyebrow">YOUR CAMPUS, YOUR COMMUNITY</p>
            <h1>Discover Events</h1>
            <p class="subtitle">
                Find experiences, meet people, and make the most of college.
            </p>
        </div>
    </header>

    <!-- H05: SEARCH BAR -->
    <section class="search-section">
        <div class="search-wrapper">
            <span class="search-icon">⌕</span>

            <input
                type="search"
                placeholder="Search events, organizations, or locations..."
                bind:value={searchQuery}
                aria-label="Search events"
            />

            {#if searchQuery}
                <button
                    class="clear-button"
                    onclick={() => searchQuery = ''}
                    aria-label="Clear search"
                >
                    ×
                </button>
            {/if}
        </div>
    </section>

    <!-- H05: CATEGORY FILTERS -->
    <section class="filter-section">
        <div class="filter-heading">
            <h2>Explore categories</h2>
            <button class="reset-button" onclick={resetFilters}>
                Clear filters
            </button>
        </div>

        <div class="category-filters">
            {#each categories as category}
                <button
                    class="filter-chip"
                    class:active={selectedCategory === category}
                    onclick={() => selectedCategory = category}
                    aria-pressed={selectedCategory === category}
                >
                    {category}
                </button>
            {/each}
        </div>
    </section>

    <!-- EVENT RESULTS -->
    <section class="events-section">
        <div class="results-heading">
            <h2>
                {selectedCategory === 'All'
                    ? 'Upcoming Events'
                    : `${selectedCategory} Events`}
            </h2>

            <span class="result-count">
                {filteredEvents.length} events
            </span>
        </div>

        {#if filteredEvents.length > 0}
            <div class="events-grid">
                {#each filteredEvents as event (event.id)}
                    <article class="event-card">

                        <div class="event-card-top">
                            <span class="event-date">
                                {event.date}
                            </span>

                            <!-- H04: EVENT CATEGORY CHIP -->
                            <span class="category-chip {event.category.toLowerCase()}">
                                {event.category}
                            </span>
                        </div>

                        <div class="event-content">
                            <h3>{event.name}</h3>

                            <p class="organization">
                                {event.organization}
                            </p>

                            <p class="description">
                                {event.description}
                            </p>
                        </div>

                        <div class="event-details">
                            <span>📍 {event.location}</span>
                            <span>🕒 {event.time}</span>
                        </div>

                    </article>
                {/each}
            </div>

        {:else}
            <div class="empty-state">
                <div class="empty-icon">⌕</div>
                <h3>No events found</h3>
                <p>
                    Try another search or choose a different category.
                </p>
                <button class="reset-empty" onclick={resetFilters}>
                    Clear filters
                </button>
            </div>
        {/if}
    </section>

</main>

<style>
    :global(*) {
        box-sizing: border-box;
    }

    .page-container {
        max-width: 1150px;
        margin: 0 auto;
        padding: 48px 32px;
        color: #272044;
    }

    .page-header {
        margin-bottom: 32px;
    }

    .eyebrow {
        color: #8065bd;
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 2px;
    }

    h1 {
        font-size: 34px;
        margin: 8px 0;
    }

    .subtitle {
        color: #777;
        font-size: 15px;
    }

    /* SEARCH */
    .search-wrapper {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 0 16px;
        border: 1px solid #e5e1ed;
        border-radius: 10px;
        background: white;
    }

    .search-wrapper:focus-within {
        border-color: #8065bd;
        box-shadow: 0 0 0 3px #8065bd18;
    }

    .search-icon {
        font-size: 25px;
        color: #8065bd;
    }

    .search-wrapper input {
        flex: 1;
        min-width: 0;
        padding: 16px 0;
        border: none;
        outline: none;
        font-size: 14px;
        background: transparent;
    }

    .clear-button {
        border: none;
        background: transparent;
        font-size: 23px;
        color: #777;
        cursor: pointer;
    }

    /* FILTERS */
    .filter-section {
        margin: 32px 0;
    }

    .filter-heading,
    .results-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        margin-bottom: 16px;
    }

    h2 {
        font-size: 19px;
        margin: 0;
    }

    .reset-button {
        border: none;
        background: none;
        color: #8065bd;
        cursor: pointer;
        font-size: 13px;
        font-weight: 600;
    }

    .category-filters {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
    }

    .filter-chip {
        padding: 9px 18px;
        border: 1px solid #e4e0eb;
        border-radius: 30px;
        background: white;
        color: #555;
        cursor: pointer;
        font-size: 13px;
        transition: 0.2s;
    }

    .filter-chip:hover {
        border-color: #8065bd;
        color: #7354bd;
    }

    .filter-chip.active {
        background: #7354bd;
        color: white;
        border-color: #7354bd;
    }

    /* EVENT CARDS */
    .results-heading {
        margin-bottom: 20px;
    }

    .result-count {
        font-size: 13px;
        color: #888;
    }

    .events-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 20px;
    }

    .event-card {
        padding: 22px;
        border: 1px solid #ebe8f0;
        border-radius: 14px;
        background: white;
        transition: 0.2s;
    }

    .event-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 6px 20px #0000000c;
    }

    .event-card-top {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;
    }

    .event-date {
        font-size: 12px;
        color: #777;
        font-weight: 600;
    }

    /* H04: CATEGORY CHIP COLORS */
    .category-chip {
        padding: 6px 11px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 700;
    }

    .academic {
        background: #e8efff;
        color: #315bb0;
    }

    .social {
        background: #e4f5eb;
        color: #25834b;
    }

    .career {
        background: #f0eafa;
        color: #8050b4;
    }

    .sports {
        background: #fff0dd;
        color: #b66a16;
    }

    .event-content h3 {
        font-size: 18px;
        margin: 0 0 7px;
    }

    .organization {
        font-size: 13px;
        color: #8065bd;
        font-weight: 600;
    }

    .description {
        font-size: 13px;
        color: #777;
        line-height: 1.6;
        min-height: 42px;
    }

    .event-details {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        border-top: 1px solid #eee;
        padding-top: 15px;
        margin-top: 18px;
        font-size: 12px;
        color: #666;
    }

    /* EMPTY STATE */
    .empty-state {
        text-align: center;
        padding: 65px 20px;
        border: 1px dashed #ddd;
        border-radius: 14px;
    }

    .empty-icon {
        font-size: 38px;
        color: #8065bd;
    }

    .empty-state p {
        color: #888;
        font-size: 14px;
    }

    .reset-empty {
        margin-top: 12px;
        padding: 10px 18px;
        background: #7354bd;
        border: none;
        border-radius: 8px;
        color: white;
        cursor: pointer;
    }

    @media (max-width: 650px) {
        .page-container {
            padding: 30px 18px;
        }

        .events-grid {
            grid-template-columns: 1fr;
        }

        h1 {
            font-size: 28px;
        }
    }
</style>