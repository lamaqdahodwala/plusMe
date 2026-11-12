import { dev } from '$app/env';
import { fail, redirect } from '@sveltejs/kit';

/** @satisfies {import('./$types').Actions} */
export const actions = {
	default: async ({ cookies, locals, request }) => {
		const data = await request.formData();
		const email = data.get('email')?.toString().trim() ?? '';
		const password = data.get('password')?.toString() ?? '';

		if (!email || !password) {
			return fail(400, {
				success: false,
				message: 'Email and password are required.',
				email
			});
		}

		const { data: authData, error } = await locals.supabase.auth.signInWithPassword({
			email,
			password
		});

		if (error) {
			return fail(400, {
				success: false,
				message: error.message,
				email
			});
		}

		cookies.set('access_token', authData.session.access_token, {
			path: '/',
			httpOnly: true,
			sameSite: 'lax',
			secure: !dev,
			maxAge: authData.session.expires_in
		});

		redirect(303, '/home');
	}
};
