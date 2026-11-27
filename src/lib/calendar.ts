export interface CalendarItem {
	date: Date | string;
	endDate?: Date | string;
	title: string;
	description?: string;
	location?: string;
}

export interface CalendarDay {
	date: Date;
	items: CalendarItem[];
}

export const HOUR_HEIGHT = 48;
export const HOURS = Array.from({ length: 24 }, (_, hour) => hour);
export const MINUTES_IN_DAY = 24 * 60;

export function minutesSinceMidnight(value: Date | string): number {
	const date = new Date(value);
	return date.getHours() * 60 + date.getMinutes();
}

export function startOfDay(value: Date | string): Date {
	const date = new Date(value);
	return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

export function toDateKey(date: Date): string {
	const year = date.getFullYear();
	const month = String(date.getMonth() + 1).padStart(2, '0');
	const day = String(date.getDate()).padStart(2, '0');
	return `${year}-${month}-${day}`;
}

export function isSameDay(a: Date, b: Date): boolean {
	return (
		a.getFullYear() === b.getFullYear() &&
		a.getMonth() === b.getMonth() &&
		a.getDate() === b.getDate()
	);
}

export function startOfWeek(value: Date | string = new Date()): Date {
	const day = startOfDay(value);
	const sunday = new Date(day);
	sunday.setDate(day.getDate() - day.getDay());
	return sunday;
}

export function buildWeek(items: CalendarItem[], start: Date = new Date()): CalendarDay[] {
	const firstDay = startOfWeek(start);
	const days: CalendarDay[] = Array.from({ length: 7 }, (_, offset) => {
		const date = new Date(firstDay);
		date.setDate(firstDay.getDate() + offset);
		return { date, items: [] };
	});

	for (const item of items) {
		const itemDay = startOfDay(item.date);
		const day = days.find((candidate) => isSameDay(candidate.date, itemDay));
		day?.items.push(item);
	}

	for (const day of days) {
		day.items.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
	}

	return days;
}
