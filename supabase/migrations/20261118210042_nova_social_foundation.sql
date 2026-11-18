create table public.nova_social_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  display_name text not null default '',
  bio text not null default '',
  avatar_url text,
  is_private boolean not null default false,
  discoverable boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint nova_social_username_format check (username ~ '^[a-z0-9_]{3,30}$'),
  constraint nova_social_display_name_length check (char_length(display_name) <= 80),
  constraint nova_social_bio_length check (char_length(bio) <= 280),
  constraint nova_social_avatar_https check (avatar_url is null or avatar_url ~ '^https://')
);
create unique index nova_social_profiles_username_lower_uidx on public.nova_social_profiles (lower(username));
create index nova_social_profiles_discoverable_idx on public.nova_social_profiles (discoverable, lower(username));

create table public.nova_social_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  body text not null default '',
  link_url text,
  tags text[] not null default '{}',
  visibility text not null default 'public',
  status text not null default 'published',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint nova_social_posts_body_length check (char_length(body) <= 5000),
  constraint nova_social_posts_nonempty check (char_length(btrim(body)) > 0 or link_url is not null),
  constraint nova_social_posts_link_https check (link_url is null or link_url ~ '^https://'),
  constraint nova_social_posts_tags_count check (cardinality(tags) <= 8),
  constraint nova_social_posts_visibility check (visibility in ('public','followers','private')),
  constraint nova_social_posts_status check (status in ('published','hidden','deleted'))
);
create index nova_social_posts_feed_idx on public.nova_social_posts (created_at desc) where status = 'published';
create index nova_social_posts_author_idx on public.nova_social_posts (author_id, created_at desc);

create table public.nova_social_follows (
  follower_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  followed_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  status text not null default 'accepted',
  created_at timestamptz not null default now(),
  primary key (follower_id, followed_id),
  constraint nova_social_follows_not_self check (follower_id <> followed_id),
  constraint nova_social_follows_status check (status in ('pending','accepted','rejected'))
);
create index nova_social_follows_followed_idx on public.nova_social_follows (followed_id, status);

create table public.nova_social_blocks (
  blocker_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  blocked_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint nova_social_blocks_not_self check (blocker_id <> blocked_id)
);

create table public.nova_social_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.nova_social_posts(id) on delete cascade,
  author_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  parent_comment_id uuid references public.nova_social_comments(id) on delete cascade,
  body text not null,
  status text not null default 'published',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint nova_social_comments_body_length check (char_length(btrim(body)) between 1 and 2000),
  constraint nova_social_comments_status check (status in ('published','hidden','deleted'))
);
create index nova_social_comments_post_idx on public.nova_social_comments (post_id, created_at asc);

create table public.nova_social_reactions (
  post_id uuid not null references public.nova_social_posts(id) on delete cascade,
  user_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  reaction_type text not null default 'like',
  created_at timestamptz not null default now(),
  primary key (post_id, user_id),
  constraint nova_social_reactions_type check (reaction_type in ('like','love','support','funny','wow'))
);
create index nova_social_reactions_user_idx on public.nova_social_reactions (user_id, created_at desc);

create table public.nova_social_bookmarks (
  post_id uuid not null references public.nova_social_posts(id) on delete cascade,
  user_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index nova_social_bookmarks_user_idx on public.nova_social_bookmarks (user_id, created_at desc);

create table public.nova_social_preferences (
  user_id uuid primary key references public.nova_social_profiles(user_id) on delete cascade,
  feed_mode text not null default 'for_you',
  personalized_feed_enabled boolean not null default true,
  interests text[] not null default '{}',
  updated_at timestamptz not null default now(),
  constraint nova_social_preferences_mode check (feed_mode in ('for_you','following','chronological')),
  constraint nova_social_preferences_interests_count check (cardinality(interests) <= 20)
);

create table public.nova_social_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  post_id uuid references public.nova_social_posts(id) on delete set null,
  comment_id uuid references public.nova_social_comments(id) on delete set null,
  reported_user_id uuid references public.nova_social_profiles(user_id) on delete set null,
  reason text not null,
  details text not null default '',
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  constraint nova_social_reports_target check (post_id is not null or comment_id is not null or reported_user_id is not null),
  constraint nova_social_reports_reason check (reason in ('spam','harassment','hate','violence','sexual_content','misinformation','copyright','other')),
  constraint nova_social_reports_details_length check (char_length(details) <= 1500),
  constraint nova_social_reports_status check (status in ('pending','reviewing','resolved','dismissed'))
);
create index nova_social_reports_queue_idx on public.nova_social_reports (status, created_at desc);

revoke all on table public.nova_social_profiles, public.nova_social_posts, public.nova_social_follows,
  public.nova_social_blocks, public.nova_social_comments, public.nova_social_reactions,
  public.nova_social_bookmarks, public.nova_social_preferences, public.nova_social_reports
  from public, anon, authenticated;
grant select, insert, update, delete on table public.nova_social_profiles,
  public.nova_social_posts, public.nova_social_follows, public.nova_social_blocks,
  public.nova_social_comments, public.nova_social_reactions, public.nova_social_bookmarks,
  public.nova_social_preferences to authenticated;
grant insert on table public.nova_social_reports to authenticated;

alter table public.nova_social_profiles enable row level security;
alter table public.nova_social_posts enable row level security;
alter table public.nova_social_follows enable row level security;
alter table public.nova_social_blocks enable row level security;
alter table public.nova_social_comments enable row level security;
alter table public.nova_social_reactions enable row level security;
alter table public.nova_social_bookmarks enable row level security;
alter table public.nova_social_preferences enable row level security;
alter table public.nova_social_reports enable row level security;

create policy nova_social_profiles_read_discoverable on public.nova_social_profiles
  for select to authenticated using (discoverable or user_id = (select auth.uid()));
create policy nova_social_profiles_insert_self on public.nova_social_profiles
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy nova_social_profiles_update_self on public.nova_social_profiles
  for update to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy nova_social_posts_read_visible on public.nova_social_posts
  for select to authenticated using (
    (author_id = (select auth.uid()) or (
      status = 'published' and (
        visibility = 'public' or (
          visibility = 'followers' and exists (
            select 1 from public.nova_social_follows f
            where f.follower_id = (select auth.uid())
              and f.followed_id = nova_social_posts.author_id
              and f.status = 'accepted'
          )
        )
      )
    ))
    and (author_id = (select auth.uid()) or not exists (
      select 1 from public.nova_social_blocks b
      where (b.blocker_id = (select auth.uid()) and b.blocked_id = nova_social_posts.author_id)
         or (b.blocker_id = nova_social_posts.author_id and b.blocked_id = (select auth.uid()))
    ))
  );
create policy nova_social_posts_insert_self on public.nova_social_posts
  for insert to authenticated with check (author_id = (select auth.uid()) and status = 'published');
create policy nova_social_posts_update_self on public.nova_social_posts
  for update to authenticated using (author_id = (select auth.uid()))
  with check (author_id = (select auth.uid()));
create policy nova_social_posts_delete_self on public.nova_social_posts
  for delete to authenticated using (author_id = (select auth.uid()));

create policy nova_social_follows_read_participants on public.nova_social_follows
  for select to authenticated using (follower_id = (select auth.uid()) or followed_id = (select auth.uid()));
create policy nova_social_follows_insert_self on public.nova_social_follows
  for insert to authenticated with check (
    follower_id = (select auth.uid())
    and follower_id <> followed_id
    and exists (
      select 1 from public.nova_social_profiles p
      where p.user_id = followed_id
        and p.discoverable = true
        and status = case when p.is_private then 'pending' else 'accepted' end
    )
  );
create policy nova_social_follows_update_target on public.nova_social_follows
  for update to authenticated using (followed_id = (select auth.uid()) and status = 'pending')
  with check (followed_id = (select auth.uid()) and status in ('accepted','rejected'));
create policy nova_social_follows_delete_participant on public.nova_social_follows
  for delete to authenticated using (follower_id = (select auth.uid()) or followed_id = (select auth.uid()));

create policy nova_social_blocks_read_participants on public.nova_social_blocks
  for select to authenticated using (blocker_id = (select auth.uid()) or blocked_id = (select auth.uid()));
create policy nova_social_blocks_insert_self on public.nova_social_blocks
  for insert to authenticated with check (blocker_id = (select auth.uid()) and blocker_id <> blocked_id);
create policy nova_social_blocks_delete_self on public.nova_social_blocks
  for delete to authenticated using (blocker_id = (select auth.uid()));

create policy nova_social_comments_read_visible on public.nova_social_comments
  for select to authenticated using (
    status = 'published' and exists (
      select 1 from public.nova_social_posts p where p.id = nova_social_comments.post_id
    )
  );
create policy nova_social_comments_insert_visible on public.nova_social_comments
  for insert to authenticated with check (
    author_id = (select auth.uid())
    and exists (select 1 from public.nova_social_posts p where p.id = post_id and p.status = 'published')
    and (parent_comment_id is null or exists (
      select 1 from public.nova_social_comments parent
      where parent.id = parent_comment_id and parent.post_id = post_id and parent.status = 'published'
    ))
  );
create policy nova_social_comments_update_self on public.nova_social_comments
  for update to authenticated using (author_id = (select auth.uid()))
  with check (author_id = (select auth.uid()));
create policy nova_social_comments_delete_self on public.nova_social_comments
  for delete to authenticated using (author_id = (select auth.uid()));

create policy nova_social_reactions_read_visible on public.nova_social_reactions
  for select to authenticated using (
    exists (select 1 from public.nova_social_posts p where p.id = nova_social_reactions.post_id)
  );
create policy nova_social_reactions_insert_visible on public.nova_social_reactions
  for insert to authenticated with check (
    user_id = (select auth.uid())
    and exists (select 1 from public.nova_social_posts p where p.id = post_id and p.status = 'published')
  );
create policy nova_social_reactions_delete_self on public.nova_social_reactions
  for delete to authenticated using (user_id = (select auth.uid()));

create policy nova_social_bookmarks_read_self on public.nova_social_bookmarks
  for select to authenticated using (user_id = (select auth.uid()));
create policy nova_social_bookmarks_insert_visible on public.nova_social_bookmarks
  for insert to authenticated with check (
    user_id = (select auth.uid())
    and exists (select 1 from public.nova_social_posts p where p.id = post_id and p.status = 'published')
  );
create policy nova_social_bookmarks_delete_self on public.nova_social_bookmarks
  for delete to authenticated using (user_id = (select auth.uid()));

create policy nova_social_preferences_read_self on public.nova_social_preferences
  for select to authenticated using (user_id = (select auth.uid()));
create policy nova_social_preferences_insert_self on public.nova_social_preferences
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy nova_social_preferences_update_self on public.nova_social_preferences
  for update to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy nova_social_reports_insert_self on public.nova_social_reports
  for insert to authenticated with check (
    reporter_id = (select auth.uid())
    and (post_id is not null or comment_id is not null or reported_user_id is not null)
  );
