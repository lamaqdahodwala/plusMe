/** @type {import('./$types').PageServerLoad} */
export async function load({ cookies, locals }) {
	const { session, user } = await locals.safeGetSession();

	return {
		authenticated: Boolean(user),
		user,
		session,
		jwt: cookies.get('access_token') ?? null
	};
}
