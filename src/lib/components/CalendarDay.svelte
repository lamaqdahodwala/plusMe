<script lang="ts">
	import {
		HOUR_HEIGHT,
		HOURS,
		MINUTES_IN_DAY,
		minutesSinceMidnight,
		toDateKey,
		type CalendarItem
	} from '../calendar';
	import CalendarEvent from './CalendarEvent.svelte';

	interface Props {
		date: Date;
		items?: CalendarItem[];
	}

	let { date, items = [] }: Props = $props();

	const weekday = new Intl.DateTimeFormat(undefined, { weekday: 'short' });
	const monthDay = new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric' });

	function eventPosition(item: CalendarItem): string {
		const start = minutesSinceMidnight(item.date);
		const end = item.endDate ? minutesSinceMidnight(item.endDate) : start + 60;
		const duration = end > start ? end - start : 60;
		const top = (start / MINUTES_IN_DAY) * 100;
		const height = (Math.min(duration, MINUTES_IN_DAY - start) / MINUTES_IN_DAY) * 100;
		return `top: ${top}%; height: ${height}%;`;
	}
</script>

<div
	role="listitem"
	data-date={toDateKey(date)}
	class="flex min-w-[140px] flex-col border-r border-[#e9e5ef] bg-white last:border-r-0"
>
	<header
		class="sticky top-0 z-20 flex h-14 flex-col justify-center border-b border-[#e9e5ef] bg-white px-2 text-center"
	>
		<p class="text-[11px] font-bold tracking-wide text-[#8065bd] uppercase">
			{weekday.format(date)}
		</p>
		<time datetime={toDateKey(date)} class="text-sm font-semibold text-[#292536]">
			{monthDay.format(date)}
		</time>
	</header>

	<div class="relative" style="height: {HOURS.length * HOUR_HEIGHT}px">
		{#each HOURS as hour (hour)}
			<div
				class="absolute inset-x-0 border-t border-[#f0edf5]"
				style="top: {hour * HOUR_HEIGHT}px"
			></div>
		{/each}

		{#each items as item (item.title + new Date(item.date).toISOString())}
			<div class="absolute inset-x-1" style={eventPosition(item)} data-testid="calendar-event">
				<CalendarEvent {item} />
			</div>
		{/each}
	</div>
</div>
