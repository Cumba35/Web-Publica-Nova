# Global club recreation pipeline — Fútbol Nova

## Scope and honest coverage
The goal is a playable fictional counterpart for every discoverable active club in national league pyramids worldwide, with historical clubs optionally retained as non-playable legacy records. "Every club in the world" is not a verifiable finite census: amateur, youth, reserve, women's, futsal, defunct and informal teams vary by source and season. Publish coverage by country, competition tier, season and source rather than claim a complete census.

The current in-game club database inspected before this pipeline contains Cuba's fictional league clubs. The global database has NOT yet been populated. This pipeline is the repeatable foundation for importing lawful source records and generating original assets.

## Candidate source layers
1. OpenFootball clubs — public-domain club/stadium text datasets, organized by continent and country: https://github.com/openfootball/clubs
2. OpenFootball leagues — public-domain competition catalogue and league/cup data: https://github.com/openfootball/leagues
3. Wikidata — broad discovery/reference layer for club entities and geographic context; data is CC0, but individual Wikimedia Commons media has separate licenses and is not imported as a game asset.
4. Football Origins dataset — a Wikidata-derived CSV useful for discovery and historical coverage; inspect its repository license and methodology before reuse: https://github.com/Tristan-Hotham/football-origins

No club crest, official kit image, logo, mascot, sponsor, manufacturer mark or trademarked nickname is copied into Fútbol Nova. Source names and identities are private research references only.

## Identity generation
The script at tools/generate_fictional_clubs.py reads normalized CSV rows with source_id,country_code,city,region,continent,active,level. It deliberately ignores the source club name, nickname, crest, badge, kit image and colour scheme. It creates a new fictional display name based on public geography and a generic football identity term; an original geometric SVG crest; original home, away and goalkeeper kit specifications; internal source provenance and a blocked publication state.

All generated names are drafts. Similarity screening and trademark review are required before a record becomes playable/published. A generated name is not guaranteed legally available merely because the script created it.

## Required review and release gates
1. Confirm the club is a real association-football club, country, city, active status, gender/age category, reserve status and competition tier.
2. Generate candidate identities; reject exact, phonetic, translated or visually confusing matches with the original or other clubs.
3. Search national trademark registers and WIPO Global Brand Database for relevant goods/services and territories.
4. Create and review a unique crest and three kit designs. Visual QA must catch accidental similarity and low-quality output.
5. Keep the source club reference and audit evidence private; show only the fictional club in-game.
6. Set publication_status=approved only after human/editorial review.

## Kit and crest rules
- Do not sample the source club's official palette or reproduce its shirt pattern.
- Use original palettes generated independently of source branding.
- Do not use real sponsors, kit manufacturers, badge silhouettes, monograms, mascots or stadium commercial marks.
- Use vector SVG crests and in-engine kit materials so each club has scalable assets.
- Generate home, away and goalkeeper kits with sufficient contrast; validate against opponent and referee kits.

## Data quality
Deduplicate clubs by stable source identifiers, not names. Keep country codes, city, region, competition tier, active season, club category and provenance. Do not merge men's, women's, reserve or youth teams into the parent club. Keep defunct clubs as historical entities and do not silently mark them active.

## Current state
- Identity policy: created.
- Deterministic procedural generator: created.
- Global source discovery: identified.
- Global normalized input dataset: not yet imported.
- Global club/kit/crest records: not yet generated.
- Godot integration and visual QA: pending.
