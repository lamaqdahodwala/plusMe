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

    const { data: events, error: eventsError } = await locals.supabase
        .from('Event')
        .select('eid, name, description, address, startTime, duration')
        .order('startTime', { ascending: true });

    if (eventsError) {
        console.error('Error fetching events:', eventsError.message);
    }

    return {
        // Keep your existing returned properties!
        profile,
        email: user.email,
        events: events ?? []
    };
}