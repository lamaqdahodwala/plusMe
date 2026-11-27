<script module lang="ts">
	import { defineMeta } from '@storybook/addon-svelte-csf';
	import { expect, within } from 'storybook/test';
	import { SvelteDate } from 'svelte/reactivity';
	import Calendar from '#lib/components/Calendar.svelte';

	function at(day: number, time: number): SvelteDate {
		const date = new SvelteDate();
		date.setDate(date.getDate() - date.getDay() + day);
		date.setHours(Math.floor(time), Math.round((time % 1) * 60), 0, 0);
		return date;
	}

	type EventSeed = [number, number, number, string, string, string];

	function events(seeds: EventSeed[]) {
		return seeds.map(([day, start, end, title, location, description]) => ({
			date: at(day, start),
			endDate: at(day, end),
			title,
			location,
			description
		}));
	}

	const sampleItems = events([
		[0, 10, 11.5, 'Campus Coffee Meetup', 'The Yard', 'Free coffee before class.'],
		[1, 14.5, 16, 'Study Group', 'Alexander Library', 'Collaborative review session.'],
		[1, 18, 19.5, 'Intramural Soccer', 'Werblin Gym', 'Casual scrimmage, all levels.'],
		[3, 12, 16, 'Career Fair', 'Student Center', 'Meet recruiters from 40+ companies.'],
		[5, 19, 21, 'Movie Night', 'Livingston Center', 'Free screening and snacks.'],
		[6, 9, 11, 'Volunteer Cleanup', 'Cook Campus', 'Help keep campus green.']
	]);

	const busyItems = [
		...sampleItems,
		...events([
			[2, 8, 9, 'Morning Yoga', 'College Ave Gym', 'Guided morning flow.'],
			[2, 16, 18, 'Club Fair', 'Bishop Place', 'Meet student organizations.'],
			[4, 20, 22, 'Open Mic Night', 'Douglass Lounge', 'Perform or cheer on friends.']
		])
	];

	const { Story } = defineMeta({
		title: 'Components/Calendar',
		component: Calendar,
		tags: ['autodocs'],
		args: { items: sampleItems }
	});
</script>

<Story
	name="Default"
	play={async ({ canvasElement }) => {
		const canvas = within(canvasElement);
		const days = canvas.getAllByRole('listitem');
		const dayOfWeek = (index: number) =>
			new Date(`${days[index]?.getAttribute('data-date')}T00:00:00`).getDay();

		expect(days).toHaveLength(7);
		expect(dayOfWeek(0)).toBe(0);
		expect(dayOfWeek(6)).toBe(6);

		const studyGroup = canvas.getByText('Study Group');
		const event = studyGroup.closest('[data-testid="calendar-event"]');
		expect(event?.getAttribute('style')).toContain('top:');
		expect(getComputedStyle(studyGroup).color).toBe('rgb(41, 37, 54)');

		const eventButton = canvas.getByRole('button', { name: 'Study Group' });
		const eventHeight = eventButton.getBoundingClientRect().height;
		const slotHeight = event?.getBoundingClientRect().height ?? 0;
		expect(eventHeight).toBeCloseTo(slotHeight, 1);

		await eventButton.click();
		expect(canvas.getByRole('dialog', { name: 'Event details' })).toBeTruthy();
		expect(canvas.getByText('Collaborative review session.')).toBeTruthy();

		await canvas.getByRole('button', { name: 'Study Group' }).click();
	}}
/>

<Story name="Busy week" args={{ items: busyItems }} />

<Story name="Empty week" args={{ items: [] }} />
