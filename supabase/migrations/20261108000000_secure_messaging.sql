-- 1. Ensure Profiles table has required fields (if not already present)
create table if not exists public.profiles (
    id uuid references auth.users(id) on delete cascade primary key,
    full_name text,
    username text unique,
    avatar_url text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Conversations Table
create table if not exists public.conversations (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Conversation Participants
create table if not exists public.conversation_participants (
    id uuid default gen_random_uuid() primary key,
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    user_id uuid references auth.users(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(conversation_id, user_id)
);

-- 4. User Public Keys (JWK format)
create table if not exists public.user_crypto_keys (
    user_id uuid references auth.users(id) on delete cascade primary key,
    public_key jsonb not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Encrypted Messages
create table if not exists public.messages (
    id uuid default gen_random_uuid() primary key,
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    sender_id uuid references auth.users(id) on delete cascade not null,
    ciphertext text not null,
    iv text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Performance Indexes
create index if not exists idx_conv_participants_user on public.conversation_participants(user_id);
create index if not exists idx_conv_participants_conv on public.conversation_participants(conversation_id);
create index if not exists idx_messages_conv_created on public.messages(conversation_id, created_at asc);
create index if not exists idx_profiles_username on public.profiles(username);

-- Enable Row Level Security (RLS)
alter table public.profiles enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.user_crypto_keys enable row level security;
alter table public.messages enable row level security;

-- Profiles Policies
create policy "Public profiles are viewable by everyone"
    on public.profiles for select using (true);

create policy "Users can update own profile"
    on public.profiles for update using (auth.uid() = id);

-- Keys Policies
create policy "Anyone authenticated can view public keys"
    on public.user_crypto_keys for select using (auth.role() = 'authenticated');

create policy "Users manage own public key"
    on public.user_crypto_keys for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Conversations Policies
create policy "Users can view their conversations"
    on public.conversations for select
    using (
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = id and cp.user_id = auth.uid()
        )
    );

create policy "Authenticated users can create conversations"
    on public.conversations for insert with check (auth.role() = 'authenticated');

-- Conversation Participants Policies
create policy "Participants can view member lists"
    on public.conversation_participants for select
    using (
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = conversation_id and cp.user_id = auth.uid()
        )
    );

create policy "Users can add participants"
    on public.conversation_participants for insert with check (auth.role() = 'authenticated');

-- Messages Policies
create policy "Participants can read messages"
    on public.messages for select
    using (
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = messages.conversation_id and cp.user_id = auth.uid()
        )
    );

create policy "Participants can insert messages"
    on public.messages for insert
    with check (
        auth.uid() = sender_id and
        exists (
            select 1 from public.conversation_participants cp
            where cp.conversation_id = messages.conversation_id and cp.user_id = auth.uid()
        )
    );

-- Enable Supabase Realtime Replication
alter publication supabase_realtime add table public.messages;
