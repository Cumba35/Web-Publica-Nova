#!/usr/bin/env python3
"""Build Fútbol Nova's fictional club/player database from reviewed CSV inputs.

No network scraping is performed here. The input CSVs must be collected from
permitted sources and reviewed first. This prevents assigning historical clubs
or nationality-only player lists to current professional squads by guesswork.
"""
import csv, hashlib, json, pathlib, random, re, sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
OUT_CLUBS = DATA / "global_clubs.generated.json"
OUT_PLAYERS = DATA / "global_players.generated.json"
CLUB_INPUT = DATA / "imports" / "verified_club_membership.csv"
PLAYER_INPUT = DATA / "imports" / "verified_player_squads.csv"
CATALOG = DATA / "global_league_tiers.json"
ROSTER_SIZE = 22
POSITIONS = ["POR","DFC","DFC","DFC","DFC","LI","LD","MCD","MCD","MC","MC","MC","MCO","EI","ED","DC","DC","DC","DC","SD","SD","CAI"]
GIVEN = ["Adrián","Mateo","Daniel","Gabriel","Samuel","Nicolás","Lucas","Thiago","Bruno","Álvaro","David","Marco","Alex","Leonardo","Andrés","Julián","Tomás","Emilio","Hugo","Martín"]
SURNAMES = ["Navarro","Santos","Molina","Castro","Vega","Rojas","Silva","Costa","Paredes","Méndez","Herrera","Campos","Romero","Pereira","Luna","Torres","Duarte","Medina","Acosta","Cabrera"]

def stable_int(value):
    return int(hashlib.sha256(value.encode("utf-8")).hexdigest()[:8], 16)

def read_csv(path):
    if not path.exists():
        raise SystemExit(f"Missing reviewed input: {path}")
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def make_name(city, seed):
    rng = random.Random(seed)
    base = re.sub(r"[^A-Za-zÀ-ÿ -]", "", city).strip() or "Nova"
    suffix = rng.choice(["Atlético","Deportivo","Unión","Sporting","Aurora","Horizonte","Estrella","Marítimo","Fuerza","Central"])
    return f"{suffix} {base}"

def main():
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    tier_by_country = {x["country_code"]: x["division_count"] for x in catalog["ranked_leagues"]}
    clubs_in = read_csv(CLUB_INPUT)
    players_in = read_csv(PLAYER_INPUT)
    clubs, players = [], []
    seen = set()
    for row in clubs_in:
        source_id = row["source_club_id"].strip()
        country = row["country_code"].strip().upper()
        city = row["city"].strip()
        level = int(row["division_level"])
        if not source_id or not city or country == "CUB":
            continue
        if source_id in seen:
            continue
        allowed = tier_by_country.get(country, 1)
        if level < 1 or level > allowed:
            raise ValueError(f"{source_id}: division {level} exceeds configured {allowed}")
        seen.add(source_id)
        seed = stable_int(source_id)
        name = make_name(city, seed)
        clubs.append({
            "id": f"FN-{country}-{seed:08X}", "display_name": name,
            "country_code": country, "city": city, "division_level": level,
            "competition_id": row["competition_id"], "season": row["season"],
            "source_reference_id": source_id, "fictional": True,
            "identity_type": "original_fictional_club", "status": "draft_review_required",
            "visual": {"crest":"generated_original_svg_pending","home_kit":"original_design_pending",
                       "away_kit":"original_design_pending","goalkeeper_kit":"original_design_pending"},
            "source_provenance": row.get("source_url","")
        })
    club_ids = {r["source_club_id"]: next(c["id"] for c in clubs if c["source_reference_id"] == r["source_club_id"]) for r in clubs_in if r["source_club_id"] in seen}
    for row in players_in:
        source_player = row["source_player_id"].strip()
        source_club = row["source_club_id"].strip()
        if source_club not in club_ids:
            continue
        club_id = club_ids[source_club]
        seed = stable_int(source_player)
        rng = random.Random(seed)
        level = int(row.get("division_level", "1"))
        position = row.get("position", "").strip().upper() or rng.choice(POSITIONS)
        if position not in POSITIONS:
            position = rng.choice(POSITIONS)
        overall = int(row.get("estimated_overall") or (rng.randint(52, 78) if level == 1 else rng.randint(43, 68)))
        age = int(row.get("age") or rng.randint(17, 34))
        players.append({
            "id": f"FN-P-{seed:08X}", "club_id": club_id,
            "name": f"{rng.choice(GIVEN)} {rng.choice(SURNAMES)}",
            "position": position, "age": age, "nationality": row.get("nationality", ""),
            "estimated_overall": max(35, min(90, overall)),
            "potential": max(35, min(95, overall + rng.randint(0, 15))),
            "fictional": True, "identity_type": "original_fictional_player",
            "source_reference_id": source_player, "status": "generated_draft",
            "attributes_seed": seed, "source_provenance": row.get("source_url", "")
        })

    # Fill incomplete verified squads to 22 with clearly synthetic academy/free-agent players.
    by_club = {}
    for player in players:
        by_club[player["club_id"]] = by_club.get(player["club_id"], 0) + 1
    for club in clubs:
        count = by_club.get(club["id"], 0)
        for i in range(count, ROSTER_SIZE):
            seed = stable_int(club["id"] + ":generated:" + str(i))
            rng = random.Random(seed)
            level = int(club["division_level"])
            position = POSITIONS[i % len(POSITIONS)]
            overall = rng.randint(52, 68) if level == 1 else rng.randint(43, 60)
            players.append({
                "id": f"FN-P-{seed:08X}", "club_id": club["id"],
                "name": f"{rng.choice(GIVEN)} {rng.choice(SURNAMES)}",
                "position": position, "age": rng.randint(17, 29),
                "nationality": club["country_code"], "estimated_overall": overall,
                "potential": min(92, overall + rng.randint(2, 16)),
                "fictional": True, "identity_type": "original_fictional_player",
                "source_reference_id": None, "status": "synthetic_fill_draft",
                "attributes_seed": seed, "source_provenance": "Fútbol Nova generated fallback; not a real-world roster entry"
            })
    OUT_CLUBS.write_text(json.dumps({"schema_version":"1.0.0","clubs":clubs},ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    OUT_PLAYERS.write_text(json.dumps({"schema_version":"1.0.0","roster_size":ROSTER_SIZE,"players":players},ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"clubs":len(clubs),"players":len(players),"clubs_output":str(OUT_CLUBS),"players_output":str(OUT_PLAYERS)},ensure_ascii=False))

if __name__ == "__main__":
    main()
