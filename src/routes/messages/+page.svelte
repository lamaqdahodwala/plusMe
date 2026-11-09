<script lang="ts">
    import { onMount, onDestroy } from 'svelte';
    import { supabase } from '$lib/supabase/client';
    import {
        getOrGenerateUserKeyPair,
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
        recipient_name: string;
        recipient_username: string;
        recipient_avatar?: string;
    }

    interface UserSearchResult {
        id: string;
        full_name: string;
        username: string;
        avatar_url: string;
    }

    let user = $state<any>(null);
    let keyPair = $state<CryptoKeyPair | null>(null);
    let sharedKey = $state<CryptoKey | null>(null);

    let conversations = $state<Conversation[]>([]);
    let selectedConversation = $state<Conversation | null>(null);
    let messages = $state<Message[]>([]);
    let messageText = $state('');
    let loading = $state(true);

    // Modal state for starting a new chat
    let isModalOpen = $state(false);
    let searchQuery = $state('');
    let searchResults = $state<UserSearchResult[]>([]);
    let isSearching = $state(false);

    let realtimeSub: RealtimeChannel | null = null;
    let chatScrollContainer: HTMLDivElement | null = $state(null);

    onMount(async () => {
        const { data: authData } = await supabase.auth.getUser();
        user = authData?.user;

        if (!user) return;

        // Load or generate persistent keys
        keyPair = await getOrGenerateUserKeyPair(user.id);
        const jwk = await exportPublicKey(keyPair.publicKey);

        // Sync public key with Supabase
        await supabase.from('user_crypto_keys').upsert({
            user_id: user.id,
            public_key: jwk,
            updated_at: new Date().toISOString()
        });

        await loadConversations();
        loading = false;
    });

    onDestroy(() => {
        if (realtimeSub) realtimeSub.unsubscribe();
    });

    function scrollToBottom() {
        setTimeout(() => {
            if (chatScrollContainer) {
                chatScrollContainer.scrollTop = chatScrollContainer.scrollHeight;
            }
        }, 50);
    }

    async function loadConversations() {
        // Query participants joined with profiles
        const { data } = await supabase
            .from('conversation_participants')
            .select(`
                conversation_id,
                user_id,
                profiles:user_id (
                    full_name,
                    username,
                    avatar_url
                )
            `)
            .neq('user_id', user.id);

        if (data) {
            conversations = data.map((d: any) => ({
                id: d.conversation_id,
                recipient_id: d.user_id,
                recipient_name: d.profiles?.full_name || 'Anonymous User',
                recipient_username: d.profiles?.username || d.user_id.slice(0, 8),
                recipient_avatar: d.profiles?.avatar_url
            }));

            if (conversations.length > 0 && !selectedConversation) {
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

        // 2. Load historical messages
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
            scrollToBottom();
        }

        // 3. Realtime updates for new incoming messages
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
                    scrollToBottom();
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

    async function handleSearchUsers() {
        if (!searchQuery.trim()) {
            searchResults = [];
            return;
        }

        isSearching = true;
        const { data } = await supabase
            .from('profiles')
            .select('id, full_name, username, avatar_url')
            .neq('id', user.id)
            .ilike('username', `%${searchQuery.trim()}%`)
            .limit(10);

        searchResults = (data as UserSearchResult[]) || [];
        isSearching = false;
    }

    async function startNewChat(targetUser: UserSearchResult) {
        // Create conversation record
        const { data: convData, error: convErr } = await supabase
            .from('conversations')
            .insert({})
            .select()
            .single();

        if (convErr || !convData) return;

        // Add both participants
        await supabase.from('conversation_participants').insert([
            { conversation_id: convData.id, user_id: user.id },
            { conversation_id: convData.id, user_id: targetUser.id }
        ]);

        isModalOpen = false;
        searchQuery = '';
        searchResults = [];

        await loadConversations();

        const created = conversations.find((c) => c.id === convData.id);
        if (created) {
            await selectConversation(created);
        }
    }
</script>

<div class="chat-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h2>Messages</h2>
            <button class="new-chat-btn" onclick={() => (isModalOpen = true)}>+ New</button>
        </div>

        <div class="conversations-list">
            {#if loading}
                <p class="placeholder">Loading conversations...</p>
            {:else if conversations.length === 0}
                <div class="placeholder">
                    <p>No conversations yet.</p>
                    <button class="link-btn" onclick={() => (isModalOpen = true)}>Find people</button>
                </div>
            {:else}
                {#each conversations as conv}
                    <button
                        class="conv-item"
                        class:active={selectedConversation?.id === conv.id}
                        onclick={() => selectConversation(conv)}
                    >
                        <div class="avatar">
                            {#if conv.recipient_avatar}
                                <img src={conv.recipient_avatar} alt={conv.recipient_name} />
                            {:else}
                                {conv.recipient_name[0]}
                            {/if}
                        </div>
                        <div class="conv-info">
                            <strong>{conv.recipient_name}</strong>
                            <span>@{conv.recipient_username}</span>
                        </div>
                    </button>
                {/each}
            {/if}
        </div>
    </aside>

    <!-- Main Message Area -->
    <section class="chat-panel">
        {#if selectedConversation}
            <header class="chat-header">
                <div class="header-details">
                    <h3>{selectedConversation.recipient_name}</h3>
                    <small>@{selectedConversation.recipient_username} &bull; 🔒 E2E Encrypted</small>
                </div>
            </header>

            <div class="messages-container" bind:this={chatScrollContainer}>
                {#each messages as msg}
                    <div class="bubble-row" class:outgoing={msg.sender_id === user?.id}>
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
                    placeholder="Type an end-to-end encrypted message..."
                    bind:value={messageText}
                />
                <button type="submit" disabled={!messageText.trim()}>Send</button>
            </form>
        {:else}
            <div class="empty-state">
                <p>Select a conversation or start a new chat to begin messaging.</p>
            </div>
        {/if}
    </section>
</div>

<!-- New Chat Modal -->
{#if isModalOpen}
    <div class="modal-backdrop" onclick={() => (isModalOpen = false)}>
        <div class="modal-card" onclick={(e) => e.stopPropagation()}>
            <div class="modal-header">
                <h3>Start a Conversation</h3>
                <button class="close-btn" onclick={() => (isModalOpen = false)}>&times;</button>
            </div>

            <div class="modal-search">
                <input
                    type="text"
                    placeholder="Search by NetID or username..."
                    bind:value={searchQuery}
                    oninput={handleSearchUsers}
                />
            </div>

            <div class="search-results">
                {#if isSearching}
                    <p class="status-text">Searching...</p>
                {:else if searchResults.length === 0 && searchQuery.trim()}
                    <p class="status-text">No users found.</p>
                {:else}
                    {#each searchResults as person}
                        <button class="search-item" onclick={() => startNewChat(person)}>
                            <div class="avatar small">
                                {person.full_name ? person.full_name[0] : person.username[0]}
                            </div>
                            <div class="item-info">
                                <strong>{person.full_name || person.username}</strong>
                                <span>@{person.username}</span>
                            </div>
                            <span class="chat-action">Chat &rarr;</span>
                        </button>
                    {/each}
                {/if}
            </div>
        </div>
    </div>
{/if}

<style>
    .chat-layout {
        display: flex;
        height: calc(100vh - 64px);
        background: #ffffff;
        border-radius: 12px;
        overflow: hidden;
        border: 1px solid #e2e8f0;
        margin: 12px;
    }

    .sidebar {
        width: 340px;
        border-right: 1px solid #e2e8f0;
        display: flex;
        flex-direction: column;
        background: #f8fafc;
    }

    .sidebar-header {
        padding: 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #e2e8f0;
    }

    .sidebar-header h2 {
        margin: 0;
        font-size: 1.2rem;
        font-weight: 700;
    }

    .new-chat-btn {
        background: #2563eb;
        color: #ffffff;
        border: none;
        padding: 6px 14px;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
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
        border-bottom: 1px solid #f1f5f9;
    }

    .conv-item:hover, .conv-item.active {
        background: #e2e8f0;
    }

    .avatar {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        background: #3b82f6;
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        overflow: hidden;
    }

    .avatar.small {
        width: 36px;
        height: 36px;
        font-size: 0.9rem;
    }

    .avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .conv-info strong {
        display: block;
        color: #0f172a;
        font-size: 0.95rem;
    }

    .conv-info span {
        font-size: 0.8rem;
        color: #64748b;
    }

    .chat-panel {
        flex: 1;
        display: flex;
        flex-direction: column;
        background: #ffffff;
    }

    .chat-header {
        padding: 12px 20px;
        border-bottom: 1px solid #e2e8f0;
    }

    .chat-header h3 {
        margin: 0;
        font-size: 1.05rem;
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
        padding: 14px 20px;
        border-top: 1px solid #e2e8f0;
    }

    .compose-bar input {
        flex: 1;
        padding: 10px 14px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        outline: none;
        font-size: 0.95rem;
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

    .empty-state, .placeholder {
        padding: 32px;
        text-align: center;
        color: #94a3b8;
    }

    .link-btn {
        background: none;
        border: none;
        color: #2563eb;
        font-weight: 600;
        cursor: pointer;
        margin-top: 8px;
    }

    /* Modal Styles */
    .modal-backdrop {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 50;
    }

    .modal-card {
        background: #ffffff;
        width: 100%;
        max-width: 440px;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
    }

    .modal-header {
        padding: 16px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #e2e8f0;
    }

    .modal-header h3 {
        margin: 0;
        font-size: 1.1rem;
    }

    .close-btn {
        background: none;
        border: none;
        font-size: 1.4rem;
        cursor: pointer;
        color: #64748b;
    }

    .modal-search {
        padding: 16px 20px;
        border-bottom: 1px solid #f1f5f9;
    }

    .modal-search input {
        width: 100%;
        box-sizing: border-box;
        padding: 10px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        outline: none;
    }

    .search-results {
        max-height: 280px;
        overflow-y: auto;
    }

    .search-item {
        display: flex;
        align-items: center;
        gap: 12px;
        width: 100%;
        padding: 10px 20px;
        border: none;
        background: transparent;
        text-align: left;
        cursor: pointer;
        border-bottom: 1px solid #f8fafc;
    }

    .search-item:hover {
        background: #f1f5f9;
    }

    .item-info {
        flex: 1;
    }

    .item-info strong {
        display: block;
        font-size: 0.95rem;
    }

    .item-info span {
        font-size: 0.8rem;
        color: #64748b;
    }

    .chat-action {
        font-size: 0.85rem;
        font-weight: 600;
        color: #2563eb;
    }

    .status-text {
        padding: 20px;
        text-align: center;
        color: #94a3b8;
    }
</style>
