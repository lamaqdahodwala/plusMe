console.log('Supabase environment check:', {
    hasUrl: Boolean(PUBLIC_SUPABASE_URL),
    hasKey: Boolean(PUBLIC_SUPABASE_PUBLISHABLE_KEY)
});
import { createServerClient } from '@supabase/ssr';
import {
    PUBLIC_SUPABASE_URL,
    PUBLIC_SUPABASE_PUBLISHABLE_KEY
} from '$app/env/public';

export async function handle({ event, resolve }) {
    event.locals.supabase = createServerClient(
        PUBLIC_SUPABASE_URL,
        PUBLIC_SUPABASE_PUBLISHABLE_KEY,
        {
            cookies: {
                getAll: () => event.cookies.getAll(),

                setAll: (cookiesToSet, headers) => {
                    cookiesToSet.forEach(({ name, value, options }) => {
                        event.cookies.set(name, value, {
                            ...options,
                            path: '/'
                        });
                    });

                    if (Object.keys(headers).length > 0) {
                        event.setHeaders(headers);
                    }
                }
            }
        }
    );

    // Verify the current user's session
    event.locals.safeGetSession = async () => {
        const {
            data: { session }
        } = await event.locals.supabase.auth.getSession();

        if (!session) {
            return { session: null, user: null };
        }

        const {
            data: { user },
            error
        } = await event.locals.supabase.auth.getUser();

        if (error) {
            return { session: null, user: null };
        }

        return { session, user };
    };

    return resolve(event, {
        filterSerializedResponseHeaders(name) {
            return (
                name === 'content-range' ||
                name === 'x-supabase-api-version'
            );
        }
    });
}