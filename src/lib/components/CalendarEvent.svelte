<script lang="ts">
	import type { CalendarItem } from '../calendar';

	interface Props {
		item: CalendarItem;
	}

	let { item }: Props = $props();

	const detailsId = $props.id();
	const time = new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' });

	let open = $state(false);
	let tooltipStyle = $state('');

	function formatTime(value: Date | string): string {
		return time.format(new Date(value));
	}

	function toggle(event: MouseEvent) {
		const trigger = event.currentTarget as HTMLButtonElement;
		open = !open;

		if (!open) return;

		const rect = trigger.getBoundingClientRect();
		const width = 240;
		const height = 200;
		const gap = 8;
		const left = Math.max(gap, Math.min(rect.right + gap, window.innerWidth - width - gap));
		const top = Math.max(gap, Math.min(rect.top, window.innerHeight - height - gap));

		tooltipStyle = `left: ${left}px; top: ${top}px; width: ${width}px;`;
	}

	function handleWindowClick(event: MouseEvent) {
		if (!open) return;

		const target = event.target as Element | null;
		const eventRoot = target?.closest('[data-calendar-event-root]');

		if (eventRoot?.getAttribute('data-calendar-event-root') !== detailsId) {
			open = false;
		}
	}

	function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Escape') open = false;
	}
</script>

<svelte:window onclick={handleWindowClick} onkeydown={handleKeydown} />

<div class="h-full" data-calendar-event-root={detailsId}>
	<button
		type="button"
		onclick={toggle}
		aria-expanded={open}
		aria-controls={detailsId}
		class="flex h-full w-full items-start overflow-hidden rounded-md bg-[#f1eaff] px-1.5 py-1 text-left shadow-sm transition-colors hover:bg-[#e8ddff] focus-visible:ring-2 focus-visible:ring-[#8065bd] focus-visible:outline-none"
	>
		<span class="line-clamp-2 text-[11px] leading-tight font-bold text-[#292536]">{item.title}</span
		>
	</button>

	{#if open}
		<div
			id={detailsId}
			role="dialog"
			aria-label="Event details"
			class="fixed z-[9999] max-h-[200px] overflow-y-auto rounded-lg border border-[#e9e5ef] bg-white p-3 shadow-xl"
			style={tooltipStyle}
		>
			<p class="text-sm font-bold text-[#292536]">{item.title}</p>
			<p class="mt-1 text-xs font-semibold text-[#6535a8]">
				{formatTime(item.date)}
				{#if item.endDate}
					– {formatTime(item.endDate)}
				{/if}
			</p>
			{#if item.location}
				<p class="mt-1 text-xs text-[#716c7c]">📍 {item.location}</p>
			{/if}
			{#if item.description}
				<p class="mt-2 text-xs leading-relaxed text-[#716c7c]">{item.description}</p>
			{/if}
		</div>
	{/if}
</div>
