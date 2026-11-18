#!/usr/bin/env python3
"""Validate the reference-only historical competition archive for Fútbol Nova."""
from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
HISTORY_PATH = DATA_DIR / "competition_historical_reference.json"
CATALOG_PATH = DATA_DIR / "international_club_competitions.json"
DATE_RE = re.compile(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$")


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def main() -> int:
    errors: list[str] = []
    history = load_json(HISTORY_PATH)
    catalog = load_json(CATALOG_PATH)

    mappings = history.get("competition_mappings", [])
    editions = history.get("editions", [])
    sources = history.get("sources", [])
    source_ids = [item.get("id") for item in sources]
    mapping_ids = [item.get("competition_id") for item in mappings]

    if len(mapping_ids) != len(set(mapping_ids)):
        errors.append("Duplicate competition_id in competition_mappings.")
    if len(source_ids) != len(set(source_ids)):
        errors.append("Duplicate source id.")
    if len(editions) != history.get("coverage_summary", {}).get("total_loaded_editions"):
        errors.append("coverage_summary.total_loaded_editions does not match editions length.")

    known_sources = set(source_ids)
    known_competitions = set(mapping_ids)
    seen_editions: set[tuple[str, str]] = set()
    seen_match_ids: set[str] = set()
    total_match_records = 0
    competitions_with_match_archives: set[str] = set()
    counts: Counter[str] = Counter()

    for index, edition in enumerate(editions):
        prefix = f"editions[{index}]"
        competition_id = edition.get("competition_id")
        edition_id = edition.get("edition_id")
        key = (competition_id, edition_id)
        if competition_id not in known_competitions:
            errors.append(f"{prefix}: unknown competition_id {competition_id!r}.")
        if not isinstance(edition_id, str) or not edition_id.strip():
            errors.append(f"{prefix}: edition_id is missing.")
        if key in seen_editions:
            errors.append(f"{prefix}: duplicate edition {key!r}.")
        seen_editions.add(key)
        counts[competition_id] += 1

        refs = edition.get("source_ids")
        if not isinstance(refs, list) or not refs:
            errors.append(f"{prefix}: source_ids must be a non-empty list.")
        elif any(ref not in known_sources for ref in refs):
            errors.append(f"{prefix}: source_ids contains an unknown source.")

        if edition.get("real_club_names_reference_only") is not True:
            errors.append(f"{prefix}: real club names are not marked reference-only.")
        if edition.get("real_player_names_reference_only") is not True:
            errors.append(f"{prefix}: real player names are not marked reference-only.")

        scorers = edition.get("top_scorers", [])
        if not isinstance(scorers, list):
            errors.append(f"{prefix}: top_scorers must be a list.")
        else:
            for scorer_index, scorer in enumerate(scorers):
                if not isinstance(scorer, dict) or not scorer.get("real_name"):
                    errors.append(f"{prefix}.top_scorers[{scorer_index}]: real_name is required.")

        final_date = edition.get("final_date")
        if final_date is not None and (not isinstance(final_date, str) or not DATE_RE.match(final_date)):
            errors.append(f"{prefix}: final_date must be YYYY-MM-DD or null.")

        matches = edition.get("matches")
        if matches is not None:
            if not isinstance(matches, list):
                errors.append(f"{prefix}: matches must be a list.")
            else:
                competitions_with_match_archives.add(str(competition_id))
                total_match_records += len(matches)
                match_source_ids = edition.get("matches_source_ids", [])
                if not isinstance(match_source_ids, list) or not match_source_ids:
                    errors.append(f"{prefix}: matches_source_ids must be a non-empty list.")
                elif any(source_id not in known_sources for source_id in match_source_ids):
                    errors.append(f"{prefix}: matches_source_ids contains an unknown source.")
                if not edition.get("match_archive_status"):
                    errors.append(f"{prefix}: match_archive_status is required when matches exist.")
                previous_date = ""
                edition_goals = 0
                for match_index, match in enumerate(matches):
                    match_prefix = f"{prefix}.matches[{match_index}]"
                    if not isinstance(match, dict):
                        errors.append(f"{match_prefix}: match must be an object.")
                        continue
                    match_id = match.get("match_id")
                    if not isinstance(match_id, str) or not match_id.strip():
                        errors.append(f"{match_prefix}: match_id is required.")
                    elif match_id in seen_match_ids:
                        errors.append(f"{match_prefix}: duplicate match_id {match_id!r}.")
                    else:
                        seen_match_ids.add(match_id)
                    match_date = match.get("date")
                    if not isinstance(match_date, str) or not DATE_RE.match(match_date):
                        errors.append(f"{match_prefix}: date must be YYYY-MM-DD.")
                    else:
                        if previous_date and match_date < previous_date:
                            errors.append(f"{match_prefix}: matches are not in chronological order.")
                        previous_date = match_date
                    if not match.get("home") or not match.get("away") or match.get("home") == match.get("away"):
                        errors.append(f"{match_prefix}: distinct home and away teams are required.")
                    home_goals = match.get("home_goals")
                    away_goals = match.get("away_goals")
                    if not isinstance(home_goals, int) or home_goals < 0 or not isinstance(away_goals, int) or away_goals < 0:
                        errors.append(f"{match_prefix}: home_goals and away_goals must be non-negative integers.")
                    else:
                        edition_goals += home_goals + away_goals
                        score = match.get("score")
                        if score is not None and score != f"{home_goals}-{away_goals}":
                            errors.append(f"{match_prefix}: score text does not match numeric goals.")
                statistics = edition.get("statistics", {})
                if isinstance(statistics, dict):
                    expected_matches = statistics.get("matches_played")
                    if expected_matches is not None and expected_matches != len(matches):
                        errors.append(f"{prefix}: statistics.matches_played does not match matches length.")
                    expected_goals = statistics.get("total_goals")
                    if expected_goals is not None and expected_goals != edition_goals:
                        errors.append(f"{prefix}: statistics.total_goals does not match match results.")

        identity = edition.get("game_identity_mapping", {})
        status = identity.get("status")
        if status == "pending_identity_match":
            if identity.get("club_ids") or identity.get("player_ids"):
                errors.append(f"{prefix}: pending identity mapping must not contain game IDs.")
        elif status == "approved":
            if not (identity.get("club_ids") or identity.get("player_ids")):
                errors.append(f"{prefix}: approved identity mapping has no mapped IDs.")
            if not identity.get("approval_reference"):
                errors.append(f"{prefix}: approved identity mapping requires approval_reference.")
        else:
            errors.append(f"{prefix}: unsupported game_identity_mapping.status {status!r}.")

    mapping_by_id = {item["competition_id"]: item for item in mappings}
    for competition_id, mapping in mapping_by_id.items():
        actual = counts[competition_id]
        if mapping.get("editions_loaded") != actual:
            errors.append(
                f"{competition_id}: editions_loaded={mapping.get('editions_loaded')} but archive has {actual}."
            )

    catalog_entries = {item.get("id"): item for item in catalog.get("competitions", [])}
    if set(catalog_entries) != known_competitions:
        errors.append("Catalog competition IDs do not match historical mapping IDs.")

    for competition_id, mapping in mapping_by_id.items():
        entry = catalog_entries.get(competition_id)
        if not entry:
            continue
        reference = entry.get("historical_reference", {})
        if reference.get("competition_id") != competition_id:
            errors.append(f"{competition_id}: catalog historical_reference points to a different ID.")
        if reference.get("editions_loaded") != counts[competition_id]:
            errors.append(f"{competition_id}: catalog edition count is stale.")

    tas = mapping_by_id.get("american_super_champions_tas")
    if tas:
        if counts["american_super_champions_tas"] != 0:
            errors.append("TAS must not contain invented real-world historical editions.")
        if tas.get("reference_status") != "no_real_world_history":
            errors.append("TAS must remain marked no_real_world_history.")

    if errors:
        print("HISTORICAL ARCHIVE VALIDATION: FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print("HISTORICAL ARCHIVE VALIDATION: PASSED")
    print(f"Competitions: {len(mappings)}")
    print(f"Editions: {len(editions)}")
    print(f"Sources: {len(sources)}")
    print(f"Match results: {total_match_records}")
    print(f"Competitions with match archives: {len(competitions_with_match_archives)}")
    print(f"Concacaf Champions Cup editions: {counts['north_central_america_champions_league_nova']}")
    print("Identity mappings: pending unless explicitly approved with an approval reference")
    return 0


if __name__ == "__main__":
    sys.exit(main())
