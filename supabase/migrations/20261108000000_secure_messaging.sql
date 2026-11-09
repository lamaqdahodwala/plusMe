-- Conversations Table
create table if not exists public.conversations (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Conversation Participants
create table if not exists public.conversation_participants (
    id uuid default gen_random_uuid() primary key,
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    user_id uuid references auth.users(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(conversation_id, user_id)
);

-- User Public Keys for E2EE Key Exchange
create table if not exists public.user_crypto_keys (
    user_id uuid references auth.users(id) on delete cascade primary key,
    public_key jsonb not null, -- Exported JWK format
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Encrypted Messages Table
create table if not exists public.messages (
    id uuid default gen_random_uuid() primary key,
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    sender_id uuid references auth.users(id) on delete cascade not null,
    ciphertext text not null, -- Base64 encoded AES-GCM ciphertext
    iv text not null,         -- Base64 encoded initialization vector
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.user_crypto_keys enable row level security;
alter table public.messages enable row level security;

-- Policies: Crypto Keys
create policy "Anyone can read public keys"
    on public.user_crypto_keys for select
    using (true);

create policy "Users can upsert their own key"
    on public.user_crypto_keys for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Policies: Conversations
create policy "Users can view their conversations"
    on public.conversations for select
    using (
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = id and cp.user_id = auth.uid()
        )
    );

create policy "Authenticated users can create conversations"
    on public.conversations for insert
    with check (auth.role() = 'authenticated');

-- Policies: Conversation Participants
create policy "Participants can view member lists"
    on public.conversation_participants for select
    using (
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = conversation_id and cp.user_id = auth.uid()
        )
    );

create policy "Users can add participants"
    on public.conversation_participants for insert
    with check (auth.role() = 'authenticated');

-- Policies: Messages
create policy "Participants can read messages in conversation"
    on public.messages for select
    using (
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = messages.conversation_id and cp.user_id = auth.uid()
        )
    );

create policy "Participants can send messages"
    on public.messages for insert
    with check (
        auth.uid() = sender_id and
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = messages.conversation_id and cp.user_id = auth.uid()
        )
    );

-- Enable Realtime for Messages
alter publication supabase_realtime add table public.messages;