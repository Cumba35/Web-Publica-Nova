drop policy nova_social_follows_insert_self on public.nova_social_follows;
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
  and not exists (
    select 1 from public.nova_social_blocks b
    where (b.blocker_id = follower_id and b.blocked_id = followed_id)
       or (b.blocker_id = followed_id and b.blocked_id = follower_id)
  )
);
