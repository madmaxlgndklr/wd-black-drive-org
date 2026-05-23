#!/usr/bin/env bash
# C:\ drive duplicate & redundant file cleanup
# Based on two-pass hash scan (scan_dupes.py) + manual archive-pair detection.
# Skips: Windows, Program Files, ProgramData, AppData, RetroArch internals,
#        MO2 internals, XboxGames DLC assets, personal legal documents.

set -euo pipefail

DL="/mnt/c/Users/madma/Downloads"
DOC="/mnt/c/Users/madma/Documents"
MUSIC="/mnt/c/Users/madma/Music"
ONEDRIVE="/mnt/c/Users/madma/OneDrive"
LOG_DIR="$(dirname "$0")/logs"
LOG_FILE="$LOG_DIR/dedup_c_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN=false

for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "============================================"
echo " C:\\ Drive Duplicate & Redundant File Cleanup"
echo " Started: $(date)"
[[ "$DRY_RUN" == true ]] && echo " MODE: DRY RUN"
echo "============================================"

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

  local size human
  size=$(du -sb "$target" 2>/dev/null | cut -f1)
  human=$(du -sh "$target" 2>/dev/null | cut -f1)

  echo "[DELETE] $target"
  echo "         Reason: $reason"
  echo "         Size:   $human"

  if [[ "$DRY_RUN" == false ]]; then
    if rm -rf "$target"; then
      if ((DELETED++)); then :; fi
      BYTES_FREED=$((BYTES_FREED + size))
    else
      echo "[ERROR]  Failed: $target"
      if ((ERRORS++)); then :; fi
    fi
  else
    if ((DELETED++)); then :; fi
    BYTES_FREED=$((BYTES_FREED + size))
  fi
  echo ""
}

# ── Section 1: Downloads — hash-confirmed exact duplicates ────────────────────
echo ""
echo "── Section 1: Downloads — exact duplicates (MD5 verified) ──"

delete_item "$DL/OCP 2.4 (1).zip" \
  "Exact duplicate of 'OCP 2.4.zip' (MD5: fad0b04eefc398a029dd9f7bf988a95c)"

delete_item "$DL/Tricia_Bardon_Max_Barrett_SMS_Exchange_20250905_20260331 (1).zip" \
  "Exact duplicate of same-named zip without (1) suffix (MD5: b853789b42fc979062df6c227d68b085)"

delete_item "$DL/Mod Organizer 2-6194-2-4-4-1640622655.exe" \
  "Identical to Mod.Organizer-2.4.4.exe (MD5: eaef94e94350807d6a73151483f0d46b) — keeping clean-named version"

delete_item "$DL/CoD1Remastered-1672-1-1670882777.7z" \
  "Identical to CoD1RemasteredReshade.7z (same MD5) — keeping descriptively-named version"

delete_item "$DL/CM-Punk-Cult-of-Personality.mp3" \
  "Same file present in Music/WWE 2K/ — keeping organized copy"

delete_item "$DL/Me_Tricia_Bardon.docx" \
  "Same file present in Documents/Tricia_Bardon.../Tricia_Bardon...(1)/ — keeping organized copy"

# ── Section 2: Downloads — archive+extracted pairs ────────────────────────────
echo "── Section 2: Downloads — compressed+uncompressed pairs ──"

delete_item "$DL/retropie-buster-4.8-rpi1_zero.img" \
  "Uncompressed image (2.9G); compressed retropie-buster-4.8-rpi1_zero.img.gz (848M) retained — decompress to re-flash if needed"

# ── Section 3: Downloads — redundant installers (software already installed) ──
echo "── Section 3: Downloads — redundant installers ──"

delete_item "$DL/Wondershare_UniConverter_Installer.exe" \
  "Wondershare UniConverter already installed at G:\\Software\\Wondershare UniConverter 17"

delete_item "$DL/uniconverter_setup_full14236.exe" \
  "Older Wondershare UniConverter installer; software already installed on G:\\"

# ── Section 4: Music/WWE 2K — in-folder copy ─────────────────────────────────
echo "── Section 4: Music/WWE 2K — accidental in-folder copy ──"

delete_item "$MUSIC/WWE 2K/CM-Punk-Cult-of-Personality - Copy.mp3" \
  "Windows 'Copy' duplicate of CM-Punk-Cult-of-Personality.mp3 in same folder"

# ── Section 5: OneDrive/Christian Kane — WWE2K save data (wrong location) ────
echo "── Section 5: OneDrive/Christian Kane — misplaced WWE 2K save data ──"
echo "   (Identical data lives in Music/WWE 2K/1942660/ — Christian Kane folder is wrong location)"

delete_item "$ONEDRIVE/Christian Kane/1942660" \
  "WWE 2K save data (Steam AppID 1942660) misplaced in Christian Kane music folder; identical copy in Music/WWE 2K/1942660/"

# ── Section 6: OneDrive/Music/WWE 2K — mirrors of local Music copies ─────────
echo "── Section 6: OneDrive/Music/WWE 2K — mirrors of Music/WWE 2K ──"

for f in \
  "CM-Punk-Cult-of-Personality.mp3" \
  "CM-Punk-Cult-of-Personality - Copy.mp3" \
  "CM-Punk-Cult-of-Personality.wem" \
  "blankre.wem" \
  "Cody Rhodes.wem" \
  "D-Generation X.wem"
do
  delete_item "$ONEDRIVE/Music/WWE 2K/$f" \
    "Mirror of Music/WWE 2K/$f — keeping local copy"
done

# ── Section 7: OneDrive/Pictures — duplicate downloads & renamed copies ───────
echo "── Section 7: OneDrive/Pictures — duplicate video files ──"

TRICIA_PIC="$ONEDRIVE/Pictures/Tricia Photos_Videos"

delete_item "$TRICIA_PIC/2025-03-07 (18_47_56) - Doorbell (1).mp4" \
  "Identical to '2025-03-07 (18_47_56) - Doorbell.mp4' — downloaded multiple times"

delete_item "$TRICIA_PIC/2025-03-07 (18_47_56) - Doorbell (2).mp4" \
  "Identical to '2025-03-07 (18_47_56) - Doorbell.mp4'"

delete_item "$TRICIA_PIC/2025-03-07 (18_47_56) - Doorbell (3).mp4" \
  "Identical to '2025-03-07 (18_47_56) - Doorbell.mp4'"

delete_item "$TRICIA_PIC/cee982c775bd8daadaf079ddf9b8a5af.mp4" \
  "Same content as '2025-02-06-100913497.mp4' — hash-named duplicate; keeping date-named version"

# ── Section 8: Documents — extracted archive + zip, and smsbackup dupes ──────
echo "── Section 8: Documents — redundant zip and smsbackup duplicates ──"

BASE_TRICIA="$DOC/Tricia_Bardon_Max_Barrett_SMS_Exchange_20250905_20260331"

delete_item "$BASE_TRICIA.zip" \
  "Folder '$BASE_TRICIA' already extracted; larger complete archive also in Downloads — zip redundant"

delete_item "$BASE_TRICIA/Tricia_Bardon_Max_Barrett_SMS_Exchange_20250905_20260331(1)/Me_Tricia_Bardon.smsbackup" \
  "Identical to root-level Me_Tricia_Bardon.smsbackup in same parent — keeping root copy"

delete_item "$BASE_TRICIA/Tricia_Bardon_Max_Barrett_SMS_Exchange_20250905_20260331(2)/Me_Tricia_Bardon.smsbackup" \
  "Identical to root-level Me_Tricia_Bardon.smsbackup — keeping root copy"

# ── Summary ───────────────────────────────────────────────────────────────────
GB_FREED=$(echo "scale=2; $BYTES_FREED / 1073741824" | bc 2>/dev/null || echo "?")
MB_FREED=$(echo "scale=0; $BYTES_FREED / 1048576" | bc 2>/dev/null || echo "?")

echo "============================================"
echo " Finished: $(date)"
echo " Deleted:  $DELETED items"
echo " Skipped:  $SKIPPED items"
echo " Errors:   $ERRORS"
echo " Freed:    ~${GB_FREED} GB  (${MB_FREED} MB)"
[[ "$DRY_RUN" == true ]] && echo " (Dry-run — nothing was actually deleted)"
echo "============================================"
[[ "$ERRORS" -gt 0 ]] && exit 1 || exit 0
