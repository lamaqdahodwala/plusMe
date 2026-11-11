import { createServerClient } from '@supabase/ssr';
import {
    PUBLIC_SUPABASE_URL,
    PUBLIC_SUPABASE_PUBLISHABLE_KEY
} from '$app/env/public';

/**
 * @param {{
 *   event: import('@sveltejs/kit').RequestEvent,
 *   resolve: (
 *     event: import('@sveltejs/kit').RequestEvent,
 *     options?: {
 *       filterSerializedResponseHeaders?: (
 *         name: string,
 *         value: string
 *       ) => boolean
 *     }
 *   ) => Promise<Response>
 * }} params
 */
export const handle = async ({ event, resolve }) => {
    event.locals.supabase = createServerClient(
        PUBLIC_SUPABASE_URL,
        PUBLIC_SUPABASE_PUBLISHABLE_KEY,
        {
            cookies: {
                getAll: () => event.cookies.getAll(),

                setAll: (
                    cookiesToSet,
                    headers
                ) => {
                    cookiesToSet.forEach(({ name, value, options }) => {
                        event.cookies.set(name, value, {
                            ...options,
                            path: '/'
                        });
                    });

                    if (headers && Object.keys(headers).length > 0) {
                        event.setHeaders(headers);
                    }
                }
            }
        }
    );

    // Cache authentication verification so it only runs once per request.
    /** @type {Promise<{
     *   session: import('@supabase/supabase-js').Session | null,
     *   user: import('@supabase/supabase-js').User | null
     * }> | null} */
    let sessionPromise = null;

    event.locals.safeGetSession = () => {
        if (!sessionPromise) {
            sessionPromise = (async () => {
                const {
                    data: { session },
                    error: sessionError
                } = await event.locals.supabase.auth.getSession();

                if (sessionError || !session) {
                    return { session: null, user: null };
                }

                const {
                    data: { user },
                    error: userError
                } = await event.locals.supabase.auth.getUser();

                if (userError) {
                    return { session: null, user: null };
                }

                return { session, user };
            })();
        }

        return sessionPromise;
    };

    // Complete session verification before generating the response.
    await event.locals.safeGetSession();

    return resolve(event, {
        filterSerializedResponseHeaders: (/** @type {string} */ name) => {
            return (
                name === 'content-range' ||
                name === 'x-supabase-api-version'
            );
        }
    });
}