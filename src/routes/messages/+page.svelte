<script lang="ts">
    import { onMount, onDestroy } from 'svelte';
    import { supabase } from '$lib/supabase/client';
    import {
        generateKeyPair,
        exportPublicKey,
        importPublicKey,
        deriveSharedSecret,
        encryptMessage,
        decryptMessage
    } from '$lib/services/crypto';
    import type { RealtimeChannel } from '@supabase/supabase-js';

    interface Message {
        id: string;
        sender_id: string;
        ciphertext: string;
        iv: string;
        decryptedText?: string;
        created_at: string;
    }

    interface Conversation {
        id: string;
        recipient_id: string;
        recipient_name?: string;
    }

    // State via Svelte 5 Runes
    let user = $state<any>(null);
    let keyPair = $state<CryptoKeyPair | null>(null);
    let sharedKey = $state<CryptoKey | null>(null);

    let conversations = $state<Conversation[]>([]);
    let selectedConversation = $state<Conversation | null>(null);
    let messages = $state<Message[]>([]);
    let messageText = $state('');
    let loading = $state(true);

    let realtimeSub: RealtimeChannel | null = null;

    onMount(async () => {
        const { data: authData } = await supabase.auth.getUser();
        user = authData?.user;

        if (!user) return;

        // Initialize or retrieve E2EE keys
        keyPair = await generateKeyPair();
        const jwk = await exportPublicKey(keyPair.publicKey);

        await supabase.from('user_crypto_keys').upsert({
            user_id: user.id,
            public_key: jwk
        });

        await loadConversations();
        loading = false;
    });

    onDestroy(() => {
        if (realtimeSub) realtimeSub.unsubscribe();
    });

    async function loadConversations() {
        const { data } = await supabase
            .from('conversation_participants')
            .select('conversation_id, user_id')
            .neq('user_id', user.id);

        if (data) {
            conversations = data.map((d: any) => ({
                id: d.conversation_id,
                recipient_id: d.user_id,
                recipient_name: `User ${d.user_id.slice(0, 6)}`
            }));

            if (conversations.length > 0) {
                await selectConversation(conversations[0]);
            }
        }
    }

    async function selectConversation(conv: Conversation) {
        selectedConversation = conv;
        messages = [];

        // 1. Fetch recipient's public key
        const { data: keyData } = await supabase
            .from('user_crypto_keys')
            .select('public_key')
            .eq('user_id', conv.recipient_id)
            .single();

        if (keyData && keyPair) {
            const remotePubKey = await importPublicKey(keyData.public_key);
            sharedKey = await deriveSharedSecret(keyPair.privateKey, remotePubKey);
        }

        // 2. Fetch messages
        const { data: msgData } = await supabase
            .from('messages')
            .select('*')
            .eq('conversation_id', conv.id)
            .order('created_at', { ascending: true });

        if (msgData && sharedKey) {
            messages = await Promise.all(
                msgData.map(async (m: Message) => ({
                    ...m,
                    decryptedText: await decryptMessage(m.ciphertext, m.iv, sharedKey!)
                }))
            );
        }

        // 3. Setup Supabase Realtime Listener
        if (realtimeSub) realtimeSub.unsubscribe();

        realtimeSub = supabase
            .channel(`conversation:${conv.id}`)
            .on(
                'postgres_changes',
                {
                    event: 'INSERT',
                    schema: 'public',
                    table: 'messages',
                    filter: `conversation_id=eq.${conv.id}`
                },
                async (payload) => {
                    const newMsg = payload.new as Message;
                    if (sharedKey) {
                        newMsg.decryptedText = await decryptMessage(
                            newMsg.ciphertext,
                            newMsg.iv,
                            sharedKey
                        );
                    }
                    messages = [...messages, newMsg];
                }
            )
            .subscribe();
    }

    async function handleSend() {
        if (!messageText.trim() || !selectedConversation || !sharedKey || !user) return;

        const currentText = messageText;
        messageText = '';

        const { ciphertext, iv } = await encryptMessage(currentText, sharedKey);

        await supabase.from('messages').insert({
            conversation_id: selectedConversation.id,
            sender_id: user.id,
            ciphertext,
            iv
        });
    }
</script>

<div class="chat-layout">
    <!-- Conversations Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h2>Messages</h2>
        </div>
        <div class="conversations-list">
            {#if loading}
                <p class="placeholder">Loading conversations...</p>
            {:else if conversations.length === 0}
                <p class="placeholder">No conversations yet.</p>
            {:else}
                {#each conversations as conv}
                    <button
                        class="conv-item"
                        class:active={selectedConversation?.id === conv.id}
                        onclick={() => selectConversation(conv)}
                    >
                        <div class="avatar">{conv.recipient_name?.[0]}</div>
                        <div class="conv-info">
                            <strong>{conv.recipient_name}</strong>
                            <span>End-to-end encrypted</span>
                        </div>
                    </button>
                {/each}
            {/if}
        </div>
    </aside>

    <!-- Chat Area -->
    <section class="chat-panel">
        {#if selectedConversation}
            <header class="chat-header">
                <div>
                    <h3>{selectedConversation.recipient_name}</h3>
                    <small>🔒 P-256 ECDH &bull; AES-GCM-256</small>
                </div>
            </header>

            <div class="messages-container">
                {#each messages as msg}
                    <div
                        class="bubble-row"
                        class:outgoing={msg.sender_id === user?.id}
                    >
                        <div class="bubble">
                            <p>{msg.decryptedText || 'Decrypting...'}</p>
                            <span class="timestamp">
                                {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                            </span>
                        </div>
                    </div>
                {/each}
            </div>

            <form class="compose-bar" onsubmit={(e) => { e.preventDefault(); handleSend(); }}>
                <input
                    type="text"
                    placeholder="Write an encrypted message..."
                    bind:value={messageText}
                />
                <button type="submit" disabled={!messageText.trim()}>Send</button>
            </form>
        {:else}
            <div class="empty-state">
                <p>Select a conversation to start messaging</p>
            </div>
        {/if}
    </section>
</div>

<style>
    .chat-layout {
        display: flex;
        height: calc(100vh - 60px);
        background: #f8fafc;
        border-radius: 12px;
        overflow: hidden;
        border: 1px solid #e2e8f0;
        margin: 16px;
    }

    .sidebar {
        width: 320px;
        border-right: 1px solid #e2e8f0;
        background: #ffffff;
        display: flex;
        flex-direction: column;
    }

    .sidebar-header {
        padding: 16px;
        border-bottom: 1px solid #e2e8f0;
    }

    .sidebar-header h2 {
        font-size: 1.25rem;
        font-weight: 700;
        margin: 0;
    }

    .conversations-list {
        flex: 1;
        overflow-y: auto;
    }

    .conv-item {
        display: flex;
        align-items: center;
        gap: 12px;
        width: 100%;
        padding: 12px 16px;
        border: none;
        background: transparent;
        text-align: left;
        cursor: pointer;
        transition: background 0.15s;
    }

    .conv-item:hover, .conv-item.active {
        background: #f1f5f9;
    }

    .avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #3b82f6;
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
    }

    .conv-info strong {
        display: block;
        font-size: 0.95rem;
        color: #0f172a;
    }

    .conv-info span {
        font-size: 0.75rem;
        color: #10b981;
    }

    .chat-panel {
        flex: 1;
        display: flex;
        flex-direction: column;
        background: #ffffff;
    }

    .chat-header {
        padding: 14px 20px;
        border-bottom: 1px solid #e2e8f0;
    }

    .chat-header h3 {
        margin: 0;
        font-size: 1.1rem;
    }

    .chat-header small {
        color: #64748b;
    }

    .messages-container {
        flex: 1;
        overflow-y: auto;
        padding: 20px;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .bubble-row {
        display: flex;
        justify-content: flex-start;
    }

    .bubble-row.outgoing {
        justify-content: flex-end;
    }

    .bubble {
        max-width: 65%;
        padding: 10px 14px;
        border-radius: 12px;
        background: #f1f5f9;
        color: #1e293b;
    }

    .bubble-row.outgoing .bubble {
        background: #2563eb;
        color: #ffffff;
    }

    .bubble p {
        margin: 0;
        font-size: 0.95rem;
        word-break: break-word;
    }

    .timestamp {
        display: block;
        font-size: 0.7rem;
        margin-top: 4px;
        opacity: 0.75;
        text-align: right;
    }

    .compose-bar {
        display: flex;
        gap: 8px;
        padding: 16px 20px;
        border-top: 1px solid #e2e8f0;
    }

    .compose-bar input {
        flex: 1;
        padding: 10px 14px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        font-size: 0.95rem;
        outline: none;
    }

    .compose-bar button {
        padding: 0 18px;
        background: #2563eb;
        color: #ffffff;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
    }

    .compose-bar button:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .empty-state, .placeholder {
        padding: 24px;
        text-align: center;
        color: #94a3b8;
    }
</style>
