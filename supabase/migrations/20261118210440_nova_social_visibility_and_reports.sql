drop policy nova_social_posts_read_visible on public.nova_social_posts;
create policy nova_social_posts_read_visible on public.nova_social_posts
for select to authenticated using (
  (author_id = (select auth.uid()) or (
    status = 'published' and (
      (
        visibility = 'public'
        and exists (
          select 1 from public.nova_social_profiles author_profile
          where author_profile.user_id = nova_social_posts.author_id
            and author_profile.is_private = false
        )
      )
      or (
        visibility in ('public','followers')
        and exists (
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
drop policy nova_social_reports_insert_self on public.nova_social_reports;
create policy nova_social_reports_insert_self on public.nova_social_reports
for insert to authenticated with check (
  reporter_id = (select auth.uid())
  and (
    (post_id is not null and exists (select 1 from public.nova_social_posts p where p.id = post_id))
    or (comment_id is not null and exists (select 1 from public.nova_social_comments c where c.id = comment_id))
    or (reported_user_id is not null and exists (select 1 from public.nova_social_profiles p where p.user_id = reported_user_id))
  )
);
