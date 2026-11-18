create table public.nova_social_notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.nova_social_profiles(user_id) on delete cascade,
  actor_id uuid references public.nova_social_profiles(user_id) on delete set null,
  notification_type text not null,
  post_id uuid references public.nova_social_posts(id) on delete cascade,
  comment_id uuid references public.nova_social_comments(id) on delete set null,
  created_at timestamptz not null default now(),
  read_at timestamptz,
  constraint nova_social_notifications_type check (notification_type in ('follow_request','follow','follow_accepted','reaction','comment')),
  constraint nova_social_notifications_not_self check (actor_id is null or recipient_id <> actor_id)
);
create index nova_social_notifications_recipient_idx on public.nova_social_notifications (recipient_id, created_at desc);
create index nova_social_notifications_unread_idx on public.nova_social_notifications (recipient_id, created_at desc) where read_at is null;

revoke all on table public.nova_social_notifications from public, anon, authenticated;
grant select on table public.nova_social_notifications to authenticated;
grant update (read_at) on table public.nova_social_notifications to authenticated;
alter table public.nova_social_notifications enable row level security;
create policy nova_social_notifications_read_self on public.nova_social_notifications
  for select to authenticated using (recipient_id = (select auth.uid()));
create policy nova_social_notifications_mark_read_self on public.nova_social_notifications
  for update to authenticated using (recipient_id = (select auth.uid()))
  with check (recipient_id = (select auth.uid()));

create or replace function private.notify_nova_social_activity()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_recipient uuid;
  v_actor uuid;
  v_type text;
  v_post uuid;
  v_comment uuid;
begin
  if tg_table_name = 'nova_social_follows' then
    if tg_op = 'INSERT' then
      v_actor := new.follower_id;
      v_recipient := new.followed_id;
      v_type := case when new.status = 'pending' then 'follow_request' else 'follow' end;
    elsif tg_op = 'UPDATE' and old.status = 'pending' and new.status = 'accepted' then
      v_actor := new.followed_id;
      v_recipient := new.follower_id;
      v_type := 'follow_accepted';
    else
      return new;
    end if;
  elsif tg_table_name = 'nova_social_reactions' then
    v_actor := new.user_id;
    v_post := new.post_id;
    select p.author_id into v_recipient from public.nova_social_posts p where p.id = new.post_id;
    v_type := 'reaction';
  elsif tg_table_name = 'nova_social_comments' then
    v_actor := new.author_id;
    v_post := new.post_id;
    v_comment := new.id;
    select p.author_id into v_recipient from public.nova_social_posts p where p.id = new.post_id;
    v_type := 'comment';
  else
    return new;
  end if;

  if v_recipient is not null and v_actor is not null and v_recipient <> v_actor
     and not exists (
       select 1 from public.nova_social_blocks b
       where (b.blocker_id = v_recipient and b.blocked_id = v_actor)
          or (b.blocker_id = v_actor and b.blocked_id = v_recipient)
     ) then
    insert into public.nova_social_notifications
      (recipient_id, actor_id, notification_type, post_id, comment_id)
    values (v_recipient, v_actor, v_type, v_post, v_comment);
  end if;
  return new;
end;
$$;

create trigger nova_social_notify_follow
after insert or update of status on public.nova_social_follows
for each row execute function private.notify_nova_social_activity();

create trigger nova_social_notify_reaction
after insert on public.nova_social_reactions
for each row execute function private.notify_nova_social_activity();

create trigger nova_social_notify_comment
after insert on public.nova_social_comments
for each row execute function private.notify_nova_social_activity();
