drop policy nova_social_profiles_read_discoverable on public.nova_social_profiles;
create policy nova_social_profiles_read_discoverable on public.nova_social_profiles
for select to authenticated using (
  user_id = (select auth.uid())
  or (
    discoverable
    and not exists (
      select 1 from public.nova_social_blocks b
      where (b.blocker_id = (select auth.uid()) and b.blocked_id = nova_social_profiles.user_id)
         or (b.blocker_id = nova_social_profiles.user_id and b.blocked_id = (select auth.uid()))
    )
  )
);
