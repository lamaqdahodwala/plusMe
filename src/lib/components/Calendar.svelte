<script lang="ts">
	import { buildWeek, HOUR_HEIGHT, HOURS, toDateKey, type CalendarItem } from '../calendar';
	import CalendarDay from './CalendarDay.svelte';

	interface Props {
		items?: CalendarItem[];
		start?: Date;
	}

	let { items = [], start = new Date() }: Props = $props();

	const headingId = $props.id();
	const days = $derived(buildWeek(items, start));
	const hourFormat = new Intl.DateTimeFormat(undefined, { hour: 'numeric' });

	function hourLabel(hour: number): string {
		return hourFormat.format(new Date(2000, 0, 1, hour));
	}

	function scrollToMorning(node: HTMLDivElement) {
		node.scrollTop = 9 * HOUR_HEIGHT;
	}
</script>

<section
	aria-labelledby={headingId}
	class="flex h-screen max-h-screen w-full flex-col overflow-hidden rounded-xl border border-[#e9e5ef] bg-white"
>
	<h2 id={headingId} class="sr-only">Week calendar</h2>

	<div {@attach scrollToMorning} class="flex-1 overflow-auto" data-testid="calendar-scroll">
		<div class="flex min-w-max">
			<div class="sticky left-0 z-30 w-14 shrink-0 border-r border-[#e9e5ef] bg-white">
				<div class="sticky top-0 z-40 h-14 border-b border-[#e9e5ef] bg-white"></div>
				<div class="relative" style="height: {HOURS.length * HOUR_HEIGHT}px">
					{#each HOURS as hour (hour)}
						<span
							class="absolute right-2 text-[10px] font-medium text-[#a29dab]"
							style="top: {hour * HOUR_HEIGHT + 2}px"
						>
							{hourLabel(hour)}
						</span>
					{/each}
				</div>
			</div>

			<div role="list" class="grid flex-1 grid-cols-7" data-testid="calendar-grid">
				{#each days as day (toDateKey(day.date))}
					<CalendarDay date={day.date} items={day.items} />
				{/each}
			</div>
		</div>
	</div>
</section>
