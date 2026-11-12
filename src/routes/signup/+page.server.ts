import { fail } from '@sveltejs/kit';

/** @satisfies {import('./$types').Actions} */
export const actions = {
	default: async ({ locals, request }) => {
		const data = await request.formData();
		const username = data.get('username')?.toString().trim() ?? '';
		const email = data.get('email')?.toString().trim() ?? '';
		const password = data.get('password')?.toString() ?? '';

		if (!username || !email || !password) {
			return fail(400, {
				success: false,
				message: 'All fields are required.',
				username,
				email
			});
		}

		if (password.length < 8) {
			return fail(400, {
				success: false,
				message: 'Password must be at least 8 characters long.',
				username,
				email
			});
		}

		const { data: signUpData, error } = await locals.supabase.auth.signUp({
			email,
			password,
			options: {
				data: {
					username
				}
			}
		});

    console.log(error)

		if (error) {
			return fail(400, {
				success: false,
				message: error.message,
				username,
				email
			});
		}

		return {
			success: true,
			message: signUpData.session
				? 'Account created successfully! You can now log in.'
				: 'Account created! Check your email to verify your account.'
		};
	}
};
