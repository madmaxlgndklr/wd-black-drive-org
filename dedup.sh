#!/usr/bin/env bash
# Duplicate & redundant file cleanup script
# Targets confirmed duplicates (same filename + same byte size) and
# archive files whose extracted counterpart already exists on disk.

set -euo pipefail

DRIVE_G="/mnt/g"
DRIVE_C="/mnt/c"
LOG_DIR="$(dirname "$0")/logs"
LOG_FILE="$LOG_DIR/dedup_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN=false

for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " Duplicate & Redundant File Cleanup"
echo " Started: $(date)"
[[ "$DRY_RUN" == true ]] && echo " MODE: DRY RUN"
echo "=========================================="

DELETED=0
SKIPPED=0
ERRORS=0
BYTES_FREED=0

delete_item() {
  local target="$1"
  local reason="$2"

  if [[ ! -e "$target" ]]; then
    echo "[SKIP]  Not found: $target"
    ((SKIPPED++)) || true
    return
  fi

  local size
  size=$(du -sb "$target" 2>/dev/null | cut -f1)
  local human
  human=$(du -sh "$target" 2>/dev/null | cut -f1)

  echo "[DELETE] $target"
  echo "         Reason: $reason"
  echo "         Size:   $human"

  if [[ "$DRY_RUN" == false ]]; then
    if rm -rf "$target"; then
      ((DELETED++)) || true
      BYTES_FREED=$((BYTES_FREED + size))
    else
      echo "[ERROR]  Failed to delete: $target"
      ((ERRORS++)) || true
    fi
  else
    ((DELETED++)) || true
    BYTES_FREED=$((BYTES_FREED + size))
  fi
  echo ""
}

# ── Section 1: G:\Backup files\movies — Terminator duplicates ─────────────────
echo ""
echo "── Section 1: G:\\Backup files\\movies — Terminator duplicates ──"
echo "   (All three are identical copies already in G:\\Media\\Movies\\The Terminator Collection)"
echo ""

delete_item "$DRIVE_G/Backup files/movies/Terminator 1984" \
  "Duplicate of G:\\Media\\Movies\\The Terminator Collection\\1984.The.Terminator.1920x1040.BDRip.x264.DTS-HD.MA.mkv (identical filename + 15G size)"

delete_item "$DRIVE_G/Backup files/movies/Terminator Genisys" \
  "Duplicate of G:\\Media\\Movies\\The Terminator Collection\\2015.Terminator.Genisys.1920x804.BDRip.x264.TrueHD-Atmos.mkv (identical filename + 18G size)"

delete_item "$DRIVE_G/Backup files/movies/Terminator Salvation" \
  "Duplicate of G:\\Media\\Movies\\The Terminator Collection\\2009.Terminator.Salvation.1920x800.BDRip.x264.DTS-HD.MA.mkv (identical filename + 15G size)"

# ── Section 2: C:\Downloads — archive+folder pairs ────────────────────────────
echo "── Section 2: C:\\Downloads — archive+folder pairs ──"
echo "   (Archive deleted; extracted folder kept)"
echo ""

DOWNLOADS="$DRIVE_C/Users/madma/Downloads"

delete_item "$DOWNLOADS/Aurora.zip" \
  "Folder 'Aurora' already extracted in same directory (79M)"

delete_item "$DOWNLOADS/Call of Duty - World at War - Final Fronts (USA) (En,Fr).7z" \
  "Folder 'Call of Duty - World at War - Final Fronts (USA) (En,Fr)' already extracted (1G)"

delete_item "$DOWNLOADS/fo1-madmaxlgndklr-a17de89b61a93ef.zip" \
  "Folder 'fo1-madmaxlgndklr-a17de89b61a93ef' already extracted (22M)"

delete_item "$DOWNLOADS/XInputPlus Ver4.16.1.zip" \
  "Folder 'XInputPlus Ver4.16.1' already extracted (2M)"

# ── Section 3: C:\Downloads — redundant installer formats ────────────────────
echo "── Section 3: C:\\Downloads — redundant installer formats ──"
echo ""

delete_item "$DOWNLOADS/jetbrains-toolbox-2.2.3.20090.tar.gz" \
  "Redundant Linux/Mac format — Windows installer jetbrains-toolbox-2.2.3.20090.exe present"

# ── Summary ───────────────────────────────────────────────────────────────────
GB_FREED=$(echo "scale=1; $BYTES_FREED / 1073741824" | bc 2>/dev/null || echo "?")

echo "=========================================="
echo " Finished: $(date)"
echo " Deleted:  $DELETED items"
echo " Skipped:  $SKIPPED items"
echo " Errors:   $ERRORS"
echo " Freed:    ~${GB_FREED} GB"
[[ "$DRY_RUN" == true ]] && echo " (Dry-run — nothing was actually deleted)"
echo "=========================================="
[[ "$ERRORS" -gt 0 ]] && exit 1 || exit 0
