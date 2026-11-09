const DB_NAME = 'PlusMeSecureStorage';
const DB_VERSION = 1;
const STORE_NAME = 'crypto_keys';

function openKeyDB(): Promise<IDBDatabase> {
    return new Promise((resolve, reject) => {
        const req = indexedDB.open(DB_NAME, DB_VERSION);
        req.onupgradeneeded = () => {
            req.result.createObjectStore(STORE_NAME);
        };
        req.onsuccess = () => resolve(req.result);
        req.onerror = () => reject(req.error);
    });
}

async function saveLocalPrivateKey(userId: string, key: CryptoKey): Promise<void> {
    const db = await openKeyDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(STORE_NAME, 'readwrite');
        tx.objectStore(STORE_NAME).put(key, `ecdh_priv_${userId}`);
        tx.oncomplete = () => resolve();
        tx.onerror = () => reject(tx.error);
    });
}

async function getLocalPrivateKey(userId: string): Promise<CryptoKey | null> {
    const db = await openKeyDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(STORE_NAME, 'readonly');
        const req = tx.objectStore(STORE_NAME).get(`ecdh_priv_${userId}`);
        req.onsuccess = () => resolve(req.result || null);
        req.onerror = () => reject(req.error);
    });
}

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

/**
 * Gets the user's existing ECDH keypair from IndexedDB or generates a new one.
 */
export async function getOrGenerateUserKeyPair(userId: string): Promise<CryptoKeyPair> {
    const existingPrivate = await getLocalPrivateKey(userId);

    if (existingPrivate) {
        // Derive or load existing public key from storage or regenerate if missing
        // In Web Crypto, generating a fresh pair on initial setup and caching both is standard
        return {
            privateKey: existingPrivate,
            publicKey: await getLocalPublicKey(userId) as CryptoKey
        };
    }

    const keyPair = await crypto.subtle.generateKey(
        { name: 'ECDH', namedCurve: 'P-256' },
        false, // non-extractable private key for security
        ['deriveKey', 'deriveBits']
    );

    await saveLocalPrivateKey(userId, keyPair.privateKey);
    await saveLocalPublicKey(userId, keyPair.publicKey);

    return keyPair;
}

async function saveLocalPublicKey(userId: string, key: CryptoKey): Promise<void> {
    const db = await openKeyDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(STORE_NAME, 'readwrite');
        tx.objectStore(STORE_NAME).put(key, `ecdh_pub_${userId}`);
        tx.oncomplete = () => resolve();
        tx.onerror = () => reject(tx.error);
    });
}

async function getLocalPublicKey(userId: string): Promise<CryptoKey | null> {
    const db = await openKeyDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(STORE_NAME, 'readonly');
        const req = tx.objectStore(STORE_NAME).get(`ecdh_pub_${userId}`);
        req.onsuccess = () => resolve(req.result || null);
        req.onerror = () => reject(req.error);
    });
}

export async function exportPublicKey(key: CryptoKey): Promise<JsonWebKey> {
    return await crypto.subtle.exportKey('jwk', key);
}

export async function importPublicKey(jwk: JsonWebKey): Promise<CryptoKey> {
    return await crypto.subtle.importKey(
        'jwk',
        jwk,
        { name: 'ECDH', namedCurve: 'P-256' },
        true,
        []
    );
}

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
        return '[Encrypted message - key mismatch]';
    }
}
