// Loads the signed-in user's profile so the header can show their avatar and username.
/** @type {import('./$types').LayoutServerLoad} */
export async function load({ locals }) {
	const { session, user } = await locals.safeGetSession();

	if (!session || !user) {
		return { profile: null };
	}

	const { data: profile } = await locals.supabase
		.from('User')
		.select('uid, username, profile_pic')
		.eq('uid', user.id)
		.single();

	return { profile: profile ?? null };
}
