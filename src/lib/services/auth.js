import { dummyUsers } from '../data/dummyUsers.js';

export function login(email, password) {
    const user = dummyUsers.find(
        (user) =>
            user.email.toLowerCase() === email.toLowerCase() &&
            user.password === password
    );

    if (!user) {
        return {
            success: false,
            message: 'Incorrect email or password.'
        };
    }

    return {
        success: true,
        user: {
            id: user.id,
            name: user.name,
            email: user.email
        }
    };
}