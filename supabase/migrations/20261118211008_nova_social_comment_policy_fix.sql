drop policy nova_social_comments_insert_visible on public.nova_social_comments;
drop index if exists public.nova_social_comments_parent_idx;
alter table public.nova_social_comments drop column parent_comment_id;
create policy nova_social_comments_insert_visible on public.nova_social_comments
for insert to authenticated with check (
  author_id = (select auth.uid())
  and exists (
    select 1 from public.nova_social_posts p
    where p.id = post_id and p.status = 'published'
  )
);
