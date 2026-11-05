import { redirect } from '@sveltejs/kit';

export async function load({ locals }) {
    const { user } = await locals.safeGetSession();

    // Send logged-out visitors back to login
    if (!user) {
        redirect(303, '/');
    }

    // Get this user's profile from your existing User table
    const { data: profile, error } = await locals.supabase
        .from('User')
        .select('uid, username, profile_pic, personal_email')
        .eq('uid', user.id)
        .single();

    if (error) {
        console.error('Could not retrieve user profile:', error.message);
    }

    return {
        profile,
        email: user.email
    };
}