<script lang="ts">
	import '../routes/layout.css';
	import { page } from '$app/state';

	let { data, children } = $props();

	const profile = $derived(data.profile);
	const initial = $derived(profile?.username ? profile.username.charAt(0).toUpperCase() : '');
</script>

<div class="app-container">
	<header class="nav-bar">
		<div class="logo">
			<a href="/">+me</a>
		</div>

		<nav class="nav-links">
			<a href="/home" class:active={page.url.pathname.startsWith('/home')}>Home</a>
			<a href="/discover" class:active={page.url.pathname.startsWith('/discover')}>Discover</a>
			<a href="/messages" class:active={page.url.pathname.startsWith('/messages')}>Messages</a>
		</nav>

		<div class="header-right">
			{#if profile}
				<a href="/home" class="profile-chip" title={profile.username}>
					{#if profile.profile_pic}
						<img class="avatar" src={profile.profile_pic} alt={profile.username} />
					{:else}
						<span class="avatar avatar-initial">{initial}</span>
					{/if}
					<span class="username">{profile.username}</span>
				</a>
			{:else}
				<a href="/login" class="login-link">Log In</a>
				<a href="/signup" class="signup-btn">Sign Up</a>
			{/if}
		</div>
	</header>

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
		position: sticky;
		top: 0;
		z-index: 50;
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 16px;
		padding: 0 24px;
		height: 60px;
		background: #ffffff;
		border-bottom: 1px solid #e2e8f0;
	}

	.logo a {
		color: #8065bd;
		font-weight: 800;
		font-size: 28px;
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

	.nav-links a:hover,
	.nav-links a.active {
		color: #8065bd;
		font-weight: 600;
	}

	.header-right {
		display: flex;
		align-items: center;
		gap: 12px;
	}

	.profile-chip {
		display: flex;
		align-items: center;
		gap: 8px;
		text-decoration: none;
		color: #1e293b;
		font-weight: 600;
		font-size: 0.95rem;
	}

	.avatar {
		width: 34px;
		height: 34px;
		border-radius: 50%;
		object-fit: cover;
		display: inline-flex;
		align-items: center;
		justify-content: center;
	}

	.avatar-initial {
		background: #8065bd;
		color: #ffffff;
		font-weight: 700;
		font-size: 0.95rem;
	}

	.login-link {
		text-decoration: none;
		color: #475569;
		font-weight: 500;
		font-size: 0.95rem;
	}

	.login-link:hover {
		color: #8065bd;
	}

	.signup-btn {
		text-decoration: none;
		background: #8065bd;
		color: #ffffff;
		font-weight: 600;
		font-size: 0.95rem;
		padding: 8px 16px;
		border-radius: 999px;
	}

	.signup-btn:hover {
		background: #6f57a8;
	}

	.main-body {
		flex: 1;
	}

	@media (max-width: 640px) {
		.username {
			display: none;
		}

		.nav-links {
			gap: 12px;
		}
	}
</style>
