#!/usr/bin/env python3
"""Integrity and structure checks for the public Fútbol Nova project mirror."""
from __future__ import annotations
import csv
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "SOURCE-MIRROR.json"

def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()

def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    files = manifest["files"]
    failures = []
    checked_json = checked_csv = checked_files = 0
    for item in files:
        rel = item["path"].removeprefix("futbol-nova/")
        path = ROOT / rel
        if not path.is_file():
            failures.append(f"missing: {rel}")
            continue
        data = path.read_bytes()
        actual = git_blob_sha(data)
        if actual != item["public_blob_sha"]:
            failures.append(f"sha mismatch: {rel} expected {item['public_blob_sha']} got {actual}")
            continue
        checked_files += 1
        if path.suffix.lower() == ".json":
            try:
                json.loads(data.decode("utf-8"))
                checked_json += 1
            except Exception as exc:
                failures.append(f"invalid JSON: {rel}: {exc}")
        elif path.suffix.lower() == ".csv":
            try:
                list(csv.reader(data.decode("utf-8-sig").splitlines()))
                checked_csv += 1
            except Exception as exc:
                failures.append(f"invalid CSV: {rel}: {exc}")
    required = ["project.godot", "scenes/main.tscn", "scripts/main.gd", "tests/test_game_hub.gd", "data/league_content_manifest.json"]
    for rel in required:
        if not (ROOT / rel).is_file():
            failures.append(f"required project file missing: {rel}")
    if len(files) < 270:
        failures.append(f"unexpectedly small mirror: {len(files)} files")
    print(f"Fútbol Nova public copy: {checked_files}/{len(files)} hashes verified; {checked_json} JSON; {checked_csv} CSV.")
    if failures:
        print("\n".join(failures))
        raise SystemExit(1)
    print("PASS: source mirror integrity, project structure and structured data checks.")

if __name__ == "__main__":
    main()
