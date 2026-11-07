<script>
    let { event } = $props();
</script>

<article class="event-card">
    <span class="category">{event.category}</span>

    <h2>{event.name}</h2>

    <div class="event-details">
        <p>📅 {event.date}</p>
        <p>🕒 {event.time}</p>
        <p>📍 {event.location}</p>
    </div>

    <p class="description">{event.description}</p>
</article>

<style>
    .event-card {
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding: 20px;
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        background: white;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        transition: transform 0.2s, box-shadow 0.2s;
    }

    .event-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 5px 12px rgba(0, 0, 0, 0.1);
    }

    .category {
        align-self: flex-start;
        padding: 5px 10px;
        border-radius: 20px;
        background: #f1eaff;
        color: #6535a8;
        font-size: 0.8rem;
        font-weight: 600;
    }

    h2 {
        margin: 0;
        color: #222;
        font-size: 1.2rem;
    }

    .event-details {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .event-details p,
    .description {
        margin: 0;
        color: #555;
        font-size: 0.9rem;
        line-height: 1.5;
    }
</style>