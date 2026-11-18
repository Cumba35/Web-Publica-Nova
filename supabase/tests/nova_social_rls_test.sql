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
do $$
begin
  if (select count(*) from public.nova_social_posts) <> 3 then
    raise exception 'RLS FAIL: approved follower must see both public and follower posts from private profile';
  end if;
end $$;
select set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
insert into public.nova_social_blocks(blocker_id,blocked_id)
values ('22222222-2222-4222-8222-222222222222','11111111-1111-4111-8111-111111111111');
select set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
do $$
begin
  if (select count(*) from public.nova_social_posts) <> 1 then
    raise exception 'RLS FAIL: block must hide posts from both sides';
  end if;
end $$;
rollback;
