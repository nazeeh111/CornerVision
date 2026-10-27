#!/usr/bin/env python3
"""Verify historical source identity and explicitly recorded derivative edits."""

import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys


MANIFEST_SHA256 = "93171ed8d2ae6e742d1c1d0f2aecbe50b58741a3f8fd0b03f0b11fb23e3093db"
SOURCE_FILE_COUNT = 165
MODIFIED_SOURCE_COUNT = 19
MODIFICATIONS_SHA256 = "6810f20744f6a4d34d1e6e0547e827125aa51ad92a036863fbd4fe2a9db7d06e"


def unique_entries(pairs):
    entries = {}
    for name, digest in pairs:
        if name in entries:
            raise ValueError(f"Duplicate manifest entry: {name}")
        entries[name] = digest
    return entries


def main():
    root = Path(__file__).resolve().parent.parent
    manifest_bytes = (root / "docs" / "SOURCE-MANIFEST.json").read_bytes()
    manifest_digest = hashlib.sha256(manifest_bytes).hexdigest()
    if manifest_digest != MANIFEST_SHA256:
        raise ValueError("The preserved source manifest has changed")
    entries = json.loads(manifest_bytes, object_pairs_hook=unique_entries)
    if not isinstance(entries, dict) or len(entries) != SOURCE_FILE_COUNT:
        raise ValueError(f"Expected exactly {SOURCE_FILE_COUNT} source files")
    modifications_bytes = (root / "docs" / "SOURCE-MODIFICATIONS.json").read_bytes()
    if hashlib.sha256(modifications_bytes).hexdigest() != MODIFICATIONS_SHA256:
        raise ValueError("The derivative source modification record has changed")
    record = json.loads(modifications_bytes, object_pairs_hook=unique_entries)
    if not isinstance(record, dict) or record.get("original_manifest_sha256") != MANIFEST_SHA256:
        raise ValueError("Modification record must reference the original historical manifest")
    modifications = record.get("modified_sources")
    if not isinstance(modifications, dict) or len(modifications) != MODIFIED_SOURCE_COUNT:
        raise ValueError(f"Expected exactly {MODIFIED_SOURCE_COUNT} modified source files")
    for name, modification in modifications.items():
        if not isinstance(modification, dict) or modification.get("original_sha256") != entries.get(name):
            raise ValueError(f"Modified source original identity mismatch: {name}")
        current = modification.get("current_sha256")
        if not isinstance(current, str) or not re.fullmatch(r"[0-9a-f]{64}", current):
            raise ValueError(f"Invalid current SHA-256 for: {name}")
        if name not in entries or current == entries[name]:
            raise ValueError(f"Modified source must differ from a recorded original file: {name}")

    failures = []
    for name, expected in entries.items():
        relative = PurePosixPath(name)
        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError(f"Invalid source path: {name}")
        if not isinstance(expected, str) or not re.fullmatch(r"[0-9a-f]{64}", expected):
            raise ValueError(f"Invalid SHA-256 for: {name}")
        source = root.joinpath(*relative.parts)
        if not source.resolve().is_relative_to(root) or not source.is_file():
            failures.append(f"Missing or outside repository: {name}")
            continue
        actual = hashlib.sha256(source.read_bytes()).hexdigest()
        current_expected = modifications[name]["current_sha256"] if name in modifications else expected
        if actual != current_expected:
            failures.append(f"SHA-256 mismatch: {name}")
    if failures:
        raise ValueError("\n".join(failures))
    print(json.dumps({"status": "pass", "source_files_verified": len(entries),
                      "historical_source_files_unchanged": len(entries) - len(modifications),
                      "intentionally_modified_source_files": len(modifications),
                      "manifest_sha256": manifest_digest,
                      "modifications_sha256": MODIFICATIONS_SHA256}, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, TypeError) as error:
        print(f"FAIL source manifest: {error}", file=sys.stderr)
        sys.exit(1)
