#!/usr/bin/env python3
"""
Two-pass duplicate finder:
  Pass 1 — group files by size (cheap)
  Pass 2 — MD5 hash only the size-collision groups (expensive only where needed)
Outputs a JSON report of confirmed duplicates.
"""

import os
import sys
import hashlib
import json
from collections import defaultdict

SCAN_ROOTS = [
    "/mnt/c/Users/madma/Downloads",
    "/mnt/c/Users/madma/Documents",
    "/mnt/c/Users/madma/Music",
    "/mnt/c/Users/madma/Videos",
    "/mnt/c/Users/madma/Pictures",
    "/mnt/c/Users/madma/OneDrive",
    "/mnt/c/Users/madma/Cheathappens",
    "/mnt/c/Games",
    "/mnt/c/RetroArch-Win64",
    "/mnt/c/Modding",
    "/mnt/c/XboxGames",
]

# Skip these subtrees entirely
SKIP_DIRS = {
    "/mnt/c/Users/madma/AppData",
    "/mnt/c/Users/madma/OneDrive/AppData",
}

MIN_SIZE = 1024  # ignore files under 1 KB

def md5(path, chunk=1 << 20):
    h = hashlib.md5()
    try:
        with open(path, "rb") as f:
            while chunk_data := f.read(chunk):
                h.update(chunk_data)
        return h.hexdigest()
    except (PermissionError, OSError):
        return None

def should_skip(path):
    for skip in SKIP_DIRS:
        if path.startswith(skip):
            return True
    return False

size_map = defaultdict(list)
total_scanned = 0

print("Pass 1: indexing by size...", flush=True)
for root in SCAN_ROOTS:
    if not os.path.isdir(root):
        continue
    for dirpath, dirnames, filenames in os.walk(root):
        if should_skip(dirpath):
            dirnames.clear()
            continue
        # prune hidden/system dirs in-place
        dirnames[:] = [d for d in dirnames if not d.startswith(".") and d not in {"System Volume Information", "$RECYCLE.BIN"}]
        for fname in filenames:
            fpath = os.path.join(dirpath, fname)
            try:
                size = os.path.getsize(fpath)
                if size >= MIN_SIZE:
                    size_map[size].append(fpath)
                    total_scanned += 1
            except (PermissionError, OSError):
                pass

candidates = {sz: paths for sz, paths in size_map.items() if len(paths) > 1}
print(f"Pass 1 done: {total_scanned} files indexed, {len(candidates)} size groups with potential duplicates", flush=True)

print("Pass 2: hashing candidates...", flush=True)
hash_map = defaultdict(list)
for size, paths in candidates.items():
    for path in paths:
        digest = md5(path)
        if digest:
            hash_map[(size, digest)].append(path)

dupes = {f"{size}:{digest}": paths for (size, digest), paths in hash_map.items() if len(paths) > 1}

print(f"Pass 2 done: {len(dupes)} groups of confirmed duplicates found", flush=True)

# Build report
report = []
total_wasted = 0
for key, paths in sorted(dupes.items(), key=lambda x: -int(x[0].split(":")[0])):
    size = int(key.split(":")[0])
    wasted = size * (len(paths) - 1)
    total_wasted += wasted
    report.append({
        "size_bytes": size,
        "size_human": f"{size / (1024**2):.1f} MB" if size >= 1024**2 else f"{size / 1024:.1f} KB",
        "count": len(paths),
        "wasted_bytes": wasted,
        "paths": sorted(paths),
    })

output = {
    "total_files_scanned": total_scanned,
    "duplicate_groups": len(report),
    "total_wasted_bytes": total_wasted,
    "total_wasted_human": f"{total_wasted / (1024**3):.2f} GB",
    "duplicates": report,
}

out_path = "/home/max/test-claude-project/logs/scan_dupes_report.json"
os.makedirs(os.path.dirname(out_path), exist_ok=True)
with open(out_path, "w") as f:
    json.dump(output, f, indent=2)

print(f"\nReport written to {out_path}")
print(f"Total wasted: {output['total_wasted_human']} across {len(report)} duplicate groups")
