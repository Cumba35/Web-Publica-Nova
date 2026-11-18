create index nova_social_blocks_blocked_idx on public.nova_social_blocks (blocked_id);
create index nova_social_comments_author_idx on public.nova_social_comments (author_id);
create index nova_social_comments_parent_idx on public.nova_social_comments (parent_comment_id);
create index nova_social_reports_post_idx on public.nova_social_reports (post_id);
create index nova_social_reports_comment_idx on public.nova_social_reports (comment_id);
create index nova_social_reports_user_idx on public.nova_social_reports (reported_user_id);
create index nova_social_reports_reporter_idx on public.nova_social_reports (reporter_id);
