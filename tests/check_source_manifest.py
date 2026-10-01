#!/usr/bin/env python3
"""Verify the preserved source files without updating their manifest."""

import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys


MANIFEST_SHA256 = "93171ed8d2ae6e742d1c1d0f2aecbe50b58741a3f8fd0b03f0b11fb23e3093db"
SOURCE_FILE_COUNT = 165


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
        if actual != expected:
            failures.append(f"SHA-256 mismatch: {name}")
    if failures:
        raise ValueError("\n".join(failures))
    print(json.dumps({"status": "pass", "source_files_verified": len(entries),
                      "manifest_sha256": manifest_digest}, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, TypeError) as error:
        print(f"FAIL source manifest: {error}", file=sys.stderr)
        sys.exit(1)
