-- RLS integration test for NOVA Social.
-- Run only against a disposable staging project: all fixtures are rolled back.
begin;
insert into auth.users (id,aud,role,email,created_at,updated_at) values
('11111111-1111-4111-8111-111111111111','authenticated','authenticated','social-a@example.invalid',now(),now()),
('22222222-2222-4222-8222-222222222222','authenticated','authenticated','social-b@example.invalid',now(),now());
insert into public.nova_social_profiles (user_id,username,display_name,is_private,discoverable) values
('11111111-1111-4111-8111-111111111111','social_a_test','Social A',false,true),
('22222222-2222-4222-8222-222222222222','social_b_test','Social B',true,true);
insert into public.nova_social_posts (author_id,body,visibility) values
('11111111-1111-4111-8111-111111111111','A own post','public'),
('22222222-2222-4222-8222-222222222222','B followers post','followers'),
('22222222-2222-4222-8222-222222222222','B public post','public');
set local role authenticated;
select set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
do $$
begin
  if (select count(*) from public.nova_social_posts) <> 1 then
    raise exception 'RLS FAIL: private profile posts must be hidden before follow approval';
  end if;
  if exists (select 1 from public.nova_social_posts where body='B followers post') then
    raise exception 'RLS FAIL: user A saw a followers-only post without following';
  end if;
  begin
    insert into public.nova_social_posts(author_id,body) values
      ('22222222-2222-4222-8222-222222222222','forged post');
    raise exception 'RLS FAIL: user A inserted a post as user B';
  exception when insufficient_privilege then
    null;
  end;
end $$;
insert into public.nova_social_follows(follower_id,followed_id,status)
values ('11111111-1111-4111-8111-111111111111','22222222-2222-4222-8222-222222222222','pending');
select set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
update public.nova_social_follows set status='accepted'
where follower_id='11111111-1111-4111-8111-111111111111'
  and followed_id='22222222-2222-4222-8222-222222222222';
select set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
do $
begin
  if (select count(*) from public.nova_social_posts) <> 3 then
    raise exception 'RLS FAIL: approved follower must see both public and follower posts from private profile';
  end if;
  if not exists (select 1 from public.nova_social_notifications where recipient_id='11111111-1111-4111-8111-111111111111' and notification_type='follow_accepted') then
    raise exception 'notification missing for accepted follow request';
  end if;
end $;
select set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
do $notify$
begin
  if not exists (select 1 from public.nova_social_notifications where recipient_id='22222222-2222-4222-8222-222222222222' and notification_type='follow_request') then
    raise exception 'notification missing for incoming follow request';
  end if;
end $notify$;
insert into public.nova_social_blocks(blocker_id,blocked_id)
values ('22222222-2222-4222-8222-222222222222','11111111-1111-4111-8111-111111111111');
select set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
do $rls$
begin
  if (select count(*) from public.nova_social_posts) <> 1 then
    raise exception 'RLS FAIL: block must hide posts from both sides';
  end if;
  begin
    insert into public.nova_social_follows(follower_id,followed_id,status)
    values ('11111111-1111-4111-8111-111111111111','22222222-2222-4222-8222-222222222222','pending');
    raise exception 'RLS FAIL: a blocked user created a follow request';
  exception when insufficient_privilege then
    null;
  end;
end $rls$;
rollback;


-- Notification triggers and private notification access.
begin;
insert into auth.users (id,aud,role,email,created_at,updated_at) values
('33333333-3333-4333-8333-333333333333','authenticated','authenticated','social-notify-a@example.invalid',now(),now()),
('44444444-4444-4444-8444-444444444444','authenticated','authenticated','social-notify-b@example.invalid',now(),now());
insert into public.nova_social_profiles (user_id,username,display_name,is_private,discoverable) values
('33333333-3333-4333-8333-333333333333','social_notify_a','Notify A',false,true),
('44444444-4444-4444-8444-444444444444','social_notify_b','Notify B',false,true);
insert into public.nova_social_posts (author_id,body,visibility)
values ('33333333-3333-4333-8333-333333333333','notification test post','public');
set local role authenticated;
select set_config('request.jwt.claim.sub','44444444-4444-4444-8444-444444444444',true);
insert into public.nova_social_follows(follower_id,followed_id,status)
values ('44444444-4444-4444-8444-444444444444','33333333-3333-4333-8333-333333333333','accepted');
insert into public.nova_social_reactions(post_id,user_id,reaction_type)
select id,'44444444-4444-4444-8444-444444444444','like'
from public.nova_social_posts where body='notification test post';
insert into public.nova_social_comments(post_id,author_id,body)
select id,'44444444-4444-4444-8444-444444444444','A test comment'
from public.nova_social_posts where body='notification test post';
select set_config('request.jwt.claim.sub','33333333-3333-4333-8333-333333333333',true);
do $notify$
begin
  if (select count(*) from public.nova_social_notifications) <> 3 then
    raise exception 'notification trigger test failed: expected 3 notifications for owner';
  end if;
  if (select count(*) from public.nova_social_notifications where notification_type='reaction') <> 1 then
    raise exception 'reaction notification missing';
  end if;
  if (select count(*) from public.nova_social_notifications where notification_type='comment') <> 1 then
    raise exception 'comment notification missing';
  end if;
  update public.nova_social_notifications set read_at=now() where read_at is null;
  if (select count(*) from public.nova_social_notifications where read_at is null) <> 0 then
    raise exception 'notification read-state update failed';
  end if;
end $notify$;
select set_config('request.jwt.claim.sub','44444444-4444-4444-8444-444444444444',true);
do $notify$
begin
  if (select count(*) from public.nova_social_notifications) <> 0 then
    raise exception 'RLS FAIL: other user can read notifications';
  end if;
end $notify$;
rollback;
