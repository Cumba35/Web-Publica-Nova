#!/usr/bin/env python3
"""Validate original Fútbol Nova club display names and their source links."""
from __future__ import annotations

import json
import re
import sys
import unicodedata
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_PATH = ROOT / "data" / "base_league_clubs_2026.json"
ENGLAND_PATH = ROOT / "data" / "global_clubs.generated.json"
LEDGER_PATH = ROOT / "data" / "club_identity_name_review_2026-11-17.json"

EXPECTED_BASE = {"BRA": 60, "ITA": 100, "GER": 56, "FRA": 54, "POR": 56, "ARG": 125}
EXPECTED_ENGLAND = 68


def read_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def normalize(value: str) -> str:
    folded = unicodedata.normalize("NFKD", value.casefold())
    folded = "".join(char for char in folded if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", " ", folded).strip()


def main() -> int:
    errors: list[str] = []
    base = read_json(BASE_PATH)
    england = read_json(ENGLAND_PATH)
    ledger = read_json(LEDGER_PATH)
    base_clubs = base.get("clubs", [])
    english_clubs = england.get("clubs", [])

    counts = Counter(str(club.get("country_code", "")) for club in base_clubs)
    if len(base_clubs) != sum(EXPECTED_BASE.values()):
        errors.append(f"Expected {sum(EXPECTED_BASE.values())} six-country clubs; found {len(base_clubs)}.")
    for country, expected in EXPECTED_BASE.items():
        if counts[country] != expected:
            errors.append(f"{country}: expected {expected} clubs; found {counts[country]}.")
    if len(english_clubs) != EXPECTED_ENGLAND:
        errors.append(f"Expected {EXPECTED_ENGLAND} English clubs; found {len(english_clubs)}.")

    all_clubs = [(club, "base") for club in base_clubs] + [(club, "england") for club in english_clubs]
    ids = [str(club.get("id", "")) for club, _ in all_clubs]
    names = [normalize(str(club.get("display_name", ""))) for club, _ in all_clubs]
    if any(not value for value in ids) or len(ids) != len(set(ids)):
        errors.append("Club IDs are empty or duplicated.")
    if any(not value for value in names) or len(names) != len(set(names)):
        errors.append("Display names are empty or duplicated across the 519 clubs.")

    for club, group in all_clubs:
        club_id = str(club.get("id", "unknown"))
        display_name = str(club.get("display_name", "")).strip()
        if not display_name:
            errors.append(f"{club_id}: display_name is empty.")
        if display_name.casefold().startswith("nova "):
            errors.append(f"{club_id}: provisional 'Nova + source name' pattern remains.")
        if club.get("fictional") is not True or club.get("identity_type") != "original_fictional_club":
            errors.append(f"{club_id}: club is not flagged as an original fictional identity.")
        if not club.get("source_reference_id"):
            errors.append(f"{club_id}: source_reference_id was lost.")
        if club.get("name_origin") != "nova_original_fictional_name":
            errors.append(f"{club_id}: original name provenance is missing.")
        if club.get("club_identity_status") != "visual_and_brand_clearance_pending":
            errors.append(f"{club_id}: visual/brand release gate is not preserved.")
        if group == "base":
            reference_name = normalize(str(club.get("reference_name", "")))
            if reference_name and reference_name == normalize(display_name):
                errors.append(f"{club_id}: game display name duplicates its real reference name.")
            if club.get("name_review_status") != "original_name_created":
                errors.append(f"{club_id}: six-country original name status is missing.")
            if club.get("player_ids") != []:
                errors.append(f"{club_id}: this membership-only source must not acquire unverified player IDs.")
        else:
            if club.get("name_review_status") != "original_display_name_reviewed":
                errors.append(f"{club_id}: English display-name review status is missing.")
            if club.get("name_approval_scope") != "fictional_display_name_only":
                errors.append(f"{club_id}: English name approval scope is ambiguous.")
            if len(club.get("player_ids", [])) != 22:
                errors.append(f"{club_id}: expected 22 existing fictional player references.")

    ledger_entries = ledger.get("entries", [])
    ledger_by_id = {str(item.get("club_id", "")): item for item in ledger_entries}
    if len(ledger_entries) != 519 or len(ledger_by_id) != 519:
        errors.append("Identity-name ledger must contain 519 unique club entries.")
    for club, group in all_clubs:
        entry = ledger_by_id.get(str(club.get("id", "")))
        if not entry:
            errors.append(f"{club.get('id')}: missing identity-name ledger entry.")
        elif entry.get("display_name") != club.get("display_name"):
            errors.append(f"{club.get('id')}: ledger display name does not match source catalogue.")

    if errors:
        print("CLUB IDENTITY NAME VALIDATION: FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print("CLUB IDENTITY NAME VALIDATION: PASSED")
    print(f"Six-country provisional clubs renamed: {len(base_clubs)}")
    print(f"English display names reviewed: {len(english_clubs)}")
    print(f"Unique original display names: {len(set(names))}")
    print("Visual assets, brand clearance, membership and player-rights gates remain separate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
