// Helper functions for Base64 conversion
function bufferToBase64(buf: ArrayBuffer): string {
    return btoa(String.fromCharCode(...new Uint8Array(buf)));
}

function base64ToBuffer(b64: string): ArrayBuffer {
    const binary = atob(b64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
    }
    return bytes.buffer;
}

// Generate ECDH Key Pair
export async function generateKeyPair(): Promise<CryptoKeyPair> {
    return await crypto.subtle.generateKey(
        { name: 'ECDH', namedCurve: 'P-256' },
        true,
        ['deriveKey', 'deriveBits']
    );
}

// Export Public Key to JWK
export async function exportPublicKey(key: CryptoKey): Promise<JsonWebKey> {
    return await crypto.subtle.exportKey('jwk', key);
}

// Import Remote Public Key from JWK
export async function importPublicKey(jwk: JsonWebKey): Promise<CryptoKey> {
    return await crypto.subtle.importKey(
        'jwk',
        jwk,
        { name: 'ECDH', namedCurve: 'P-256' },
        true,
        []
    );
}

// Derive a shared AES-GCM-256 key from local private key and remote public key
export async function deriveSharedSecret(
    privateKey: CryptoKey,
    remotePublicKey: CryptoKey
): Promise<CryptoKey> {
    return await crypto.subtle.deriveKey(
        { name: 'ECDH', public: remotePublicKey },
        privateKey,
        { name: 'AES-GCM', length: 256 },
        false,
        ['encrypt', 'decrypt']
    );
}

// Encrypt plaintext with shared secret
export async function encryptMessage(
    plaintext: string,
    sharedKey: CryptoKey
): Promise<{ ciphertext: string; iv: string }> {
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const encoded = new TextEncoder().encode(plaintext);

    const encrypted = await crypto.subtle.encrypt(
        { name: 'AES-GCM', iv },
        sharedKey,
        encoded
    );

    return {
        ciphertext: bufferToBase64(encrypted),
        iv: bufferToBase64(iv.buffer)
    };
}

// Decrypt message with shared secret
export async function decryptMessage(
    ciphertext: string,
    iv: string,
    sharedKey: CryptoKey
): Promise<string> {
    try {
        const encryptedData = base64ToBuffer(ciphertext);
        const ivData = base64ToBuffer(iv);

        const decrypted = await crypto.subtle.decrypt(
            { name: 'AES-GCM', iv: new Uint8Array(ivData) },
            sharedKey,
            encryptedData
        );

        return new TextDecoder().decode(decrypted);
    } catch {
        return '[Message cannot be decrypted]';
    }
}
