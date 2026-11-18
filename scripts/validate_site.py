#!/usr/bin/env python3
"""Validate local links, assets and basic accessibility in the NOVA public site."""
from __future__ import annotations
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import re
import sys
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BASE_PREFIX = "/Web-Publica-Nova"

class PageParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.refs = []
        self.ids = set()
        self.lang = False
        self.title = False
        self.viewport = False
        self.h1 = False
        self.in_title = False
        self.images_without_alt = 0
        self.blank_without_rel = 0
        self.scripts = []
        self.legacy_menu_buttons = 0
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "html":
            self.lang = bool(a.get("lang"))
        if tag == "title":
            self.in_title = True
        if tag == "meta" and (a.get("name") or "").lower() == "viewport":
            self.viewport = True
        if tag == "h1":
            self.h1 = True
        if a.get("id"):
            self.ids.add(a["id"])
        if tag == "a" and a.get("name"):
            self.ids.add(a["name"])
        for attr in ("href", "src", "poster"):
            value = a.get(attr)
            if value:
                self.refs.append((value, tag, attr))
        if tag == "script" and a.get("src"):
            self.scripts.append(a["src"])
        if tag == "button" and "menu-toggle" in (a.get("class") or "").split():
            self.legacy_menu_buttons += 1
        if tag == "img" and "alt" not in a:
            self.images_without_alt += 1
        if tag == "a" and a.get("target") == "_blank":
            rel = set((a.get("rel") or "").lower().split())
            if not {"noopener", "noreferrer"}.issubset(rel):
                self.blank_without_rel += 1
    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False
    def handle_data(self, data):
        if self.in_title and data.strip():
            self.title = True

def local_target(source: Path, raw: str):
    raw = raw.strip()
    if not raw or raw.startswith("#"):
        return None, urlsplit(raw).fragment
    parts = urlsplit(raw)
    if parts.scheme or parts.netloc:
        return None, parts.fragment
    path = unquote(parts.path)
    if not path:
        return source, parts.fragment
    if path.startswith(BASE_PREFIX + "/"):
        path = path[len(BASE_PREFIX):]
    elif path == BASE_PREFIX:
        path = "/"
    if path.startswith("/"):
        target = ROOT / path.lstrip("/")
    else:
        target = source.parent / path
    target = target.resolve()
    try:
        target.relative_to(ROOT.resolve())
    except ValueError:
        return Path("__OUTSIDE_SITE__"), parts.fragment
    if target.is_dir():
        target = target / "index.html"
    return target, parts.fragment

errors = []
pages = sorted(ROOT.rglob("*.html"))
if not pages:
    errors.append("No HTML pages found.")
for page in pages:
    parser = PageParser()
    try:
        parser.feed(page.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"{page.relative_to(ROOT)}: HTML parse error: {exc}")
        continue
    rel = page.relative_to(ROOT)
    for ok, label in ((parser.lang, "html lang"), (parser.title, "title"), (parser.viewport, "viewport meta"), (parser.h1, "h1")):
        if not ok:
            errors.append(f"{rel}: missing {label}")
    if parser.images_without_alt:
        errors.append(f"{rel}: {parser.images_without_alt} image(s) without alt")
    if parser.blank_without_rel:
        errors.append(f"{rel}: {parser.blank_without_rel} target=_blank link(s) missing rel=noopener noreferrer")
    shared_loaders = [src for src in parser.scripts if src.lstrip("./").endswith("assets/js/site-navigation.js")]
    if len(shared_loaders) != 1:
        errors.append(f"{rel}: expected exactly one shared NOVA navigation/account loader; found {len(shared_loaders)}")
    if parser.legacy_menu_buttons:
        errors.append(f"{rel}: legacy menu-toggle button found; the user/account icon must be the single global menu control")
    if not any(raw == BASE_PREFIX + "/#donaciones" for raw, _, _ in parser.refs):
        errors.append(f"{rel}: missing global donation navigation link")
    for raw, tag, attr in parser.refs:
        if raw.startswith("https://cumba35.github.io/Nova-APPS/"):
            errors.append(f"{rel}: link points to Nova Apps GitHub Pages, which is not currently published: {raw}")
        target, fragment = local_target(page, raw)
        if target is None:
            if fragment and raw.startswith("#") and fragment not in parser.ids:
                errors.append(f"{rel}: missing in-page anchor #{fragment}")
            continue
        if target == Path("__OUTSIDE_SITE__"):
            errors.append(f"{rel}: local reference escapes site root: {raw}")
            continue
        if not target.exists():
            errors.append(f"{rel}: broken local {tag} {attr}: {raw} -> {target.relative_to(ROOT) if target.is_relative_to(ROOT) else target}")
            continue
        if fragment and target.suffix.lower() == ".html":
            dest = PageParser()
            try:
                dest.feed(target.read_text(encoding="utf-8"))
                if fragment not in dest.ids:
                    errors.append(f"{rel}: missing anchor #{fragment} in {target.relative_to(ROOT)}")
            except Exception as exc:
                errors.append(f"{rel}: could not inspect anchor target {raw}: {exc}")

# Guard the shared account/menu controller and its core interactions against regressions.
account_file = ROOT / "assets/js/account.js"
navigation_file = ROOT / "assets/js/site-navigation.js"
if not account_file.is_file():
    errors.append("Missing assets/js/account.js.")
else:
    account_js = account_file.read_text(encoding="utf-8")
    for token, label in (
        ("signInWithOAuth", "Google sign-in"),
        ("updateUser", "profile editing"),
        ("signOut", "sign-out"),
        ("nova-theme", "theme persistence"),
        ("Cambiar a modo claro", "light-mode action label"),
        ("Cambiar a modo oscuro", "dark-mode action label"),
        ('aria-expanded', "accessible menu state"),
        ('addEventListener("keydown"', "Escape-key handling"),
    ):
        if token not in account_js:
            errors.append(f"assets/js/account.js: missing {label} implementation.")
if not navigation_file.is_file():
    errors.append("Missing assets/js/site-navigation.js.")
else:
    navigation_js = navigation_file.read_text(encoding="utf-8")
    if 'assets/js/account.js' not in navigation_js:
        errors.append("assets/js/site-navigation.js: does not load the shared account/menu controller.")

# The public sitemap must list every published HTML route, and robots.txt must expose it.
sitemap_file = ROOT / "sitemap.xml"
robots_file = ROOT / "robots.txt"
if not sitemap_file.is_file():
    errors.append("Missing sitemap.xml.")
else:
    try:
        sitemap_root = ET.parse(sitemap_file).getroot()
        namespace = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
        listed = {node.text.strip() for node in sitemap_root.findall("sm:url/sm:loc", namespace) if node.text}
        expected = set()
        for page in pages:
            rel = page.relative_to(ROOT)
            route = "" if rel.as_posix() == "index.html" else rel.parent.as_posix() + "/"
            expected.add("https://cumba35.github.io/Web-Publica-Nova/" + route)
        for missing in sorted(expected - listed):
            errors.append(f"sitemap.xml: missing public route {missing}")
    except (ET.ParseError, OSError) as exc:
        errors.append(f"Invalid sitemap.xml: {exc}")
if not robots_file.is_file():
    errors.append("Missing robots.txt.")
elif "Sitemap: https://cumba35.github.io/Web-Publica-Nova/sitemap.xml" not in robots_file.read_text(encoding="utf-8"):
    errors.append("robots.txt must advertise the public sitemap.")

# NOVA Social: guard the first usable social experience and its shared data contract.
social_page = ROOT / "nova-social" / "index.html"
social_js = ROOT / "assets" / "js" / "social-feed.js"
social_css = ROOT / "assets" / "css" / "social.css"
for required_file in (social_page, social_js, social_css):
    if not required_file.is_file():
        errors.append(f"Missing NOVA Social asset: {required_file.relative_to(ROOT)}")
if social_page.is_file():
    social_html = social_page.read_text(encoding="utf-8")
    if 'type="module" src="../assets/js/social-feed.js"' not in social_html:
        errors.append("nova-social/index.html: missing social-feed module.")
    if '../assets/css/social.css' not in social_html:
        errors.append("nova-social/index.html: missing social stylesheet.")
if social_js.is_file():
    social_js_text = social_js.read_text(encoding="utf-8")
    for token, label in (
        ("nova_social_posts", "social publications"),
        ("nova_social_follows", "following relationships"),
        ("nova_social_reactions", "post reactions"),
        ("nova_social_comments", "comments"),
        ("nova_social_bookmarks", "saved posts"),
        ("nova_social_reports", "report submission"),
        ("nova_social_blocks", "blocking"),
        ("nova_social_notifications", "in-app notifications"),
        ("loadNotifications", "notification panel"),
        ("unfollowUser", "unfollow controls"),
        ("loadOutgoingRequests", "outgoing follow requests"),
        ("rankPosts", "transparent recommendation ranking"),
        ("personalized_feed_enabled", "personalization preference"),
    ):
        if token not in social_js_text:
            errors.append(f"assets/js/social-feed.js: missing {label} integration.")

# Confirm production migration files and the global menu entry stay in sync.
migration_files = (
    "20261118210209_nova_social_foundation.sql",
    "20261118210210_nova_social_fk_indexes.sql",
    "20261118210224_nova_social_profile_block_visibility.sql",
    "20261118210441_nova_social_visibility_and_reports.sql",
    "20261118210812_nova_social_follow_block_guard.sql",
    "20261118210938_nova_social_notifications.sql",
    "20261118211007_nova_social_notification_function_permissions.sql",
    "20261118211008_nova_social_comment_policy_fix.sql",
    "20261118211147_nova_social_notification_fk_indexes.sql",
)
for filename in migration_files:
    if not (ROOT / "supabase" / "migrations" / filename).is_file():
        errors.append(f"Missing production social migration: {filename}")
account_controller = ROOT / "assets" / "js" / "account.js"
if account_controller.is_file() and '["Nova Social","/Web-Publica-Nova/nova-social/"]' not in account_controller.read_text(encoding="utf-8"):
    errors.append("assets/js/account.js: Nova Social is missing from the global page menu.")

if errors:
    print("NOVA public site validation FAILED")
    for error in errors:
        print(" - " + error)
    sys.exit(1)
print(f"NOVA public site validation passed: {len(pages)} HTML page(s), all local links/assets and basic accessibility checks OK.")

