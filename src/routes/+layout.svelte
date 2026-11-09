<script lang="ts">
    import '../routes/layout.css';
    let { children } = $props();
</script>

<div class="app-container">
    <nav class="nav-bar">
        <div class="logo">
            <a href="/home">plusMe</a>
        </div>
        <div class="nav-links">
            <a href="/home">Home</a>
            <a href="/schedule">Schedule</a>
            <a href="/community">Community</a>
            <a href="/messages" class="active">Messages 📩</a>
        </div>
    </nav>

    <main class="main-body">
        {@render children()}
    </main>
</div>

<style>
    .app-container {
        display: flex;
        flex-direction: column;
        min-height: 100vh;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }

    .nav-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 24px;
        height: 60px;
        background: #ffffff;
        border-bottom: 1px solid #e2e8f0;
    }

    .logo a {
        font-size: 1.25rem;
        font-weight: 800;
        color: #2563eb;
        text-decoration: none;
    }

    .nav-links {
        display: flex;
        gap: 20px;
    }

    .nav-links a {
        text-decoration: none;
        color: #475569;
        font-weight: 500;
        font-size: 0.95rem;
        transition: color 0.15s;
    }

    .nav-links a:hover, .nav-links a.active {
        color: #2563eb;
        font-weight: 600;
    }

    .main-body {
        flex: 1;
    }
</style>
