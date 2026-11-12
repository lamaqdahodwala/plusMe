import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load({ locals }) {
	const { user } = await locals.safeGetSession();

	if (!user) {
		redirect(303, '/login');
	}

	const { data: events, error } = await locals.supabase
		.from('Event')
		.select(
			`
        eid,
        name,
        description,
        address,
        startTime,
        duration,
        link,
        EventTag (
            Tag (
                name
            )
        )
    `
		)
		.order('startTime', { ascending: true });

	if (error) {
		console.error('Error fetching events:', error.message);
	}

	return {
		events: events ?? []
	};
}
