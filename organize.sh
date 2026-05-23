#!/usr/bin/env bash
# WD_BLACK (G:) Drive Reorganization Script
# Run with --dry-run to preview without making changes.

set -euo pipefail

DRIVE="/mnt/g"
DRY_RUN=false
LOG_DIR="$(dirname "$0")/logs"
LOG_FILE="$LOG_DIR/run_$(date +%Y%m%d_%H%M%S).log"

for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " WD_BLACK Drive Reorganization"
echo " Started: $(date)"
[[ "$DRY_RUN" == true ]] && echo " MODE: DRY RUN (no files will be moved)"
echo "=========================================="

MOVED=0
SKIPPED=0
ERRORS=0

move_item() {
  local src="$1"
  local dst_dir="$2"
  local dst_name="${3:-$(basename "$src")}"
  local dst="$dst_dir/$dst_name"

  if [[ ! -e "$src" ]]; then
    echo "[SKIP]  Source not found: $src"
    ((SKIPPED++)) || true
    return
  fi
  if [[ -e "$dst" ]]; then
    echo "[SKIP]  Destination exists: $dst"
    ((SKIPPED++)) || true
    return
  fi

  echo "[MOVE]  $src"
  echo "     -> $dst"

  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$dst_dir"
    mv "$src" "$dst" && ((MOVED++)) || { echo "[ERROR] Failed to move: $src"; ((ERRORS++)) || true; }
  else
    ((MOVED++)) || true
  fi
}

make_dir() {
  local dir="$1"
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$dir"
    echo "[MKDIR] $dir"
  else
    echo "[MKDIR] $dir (dry-run)"
  fi
}

# ── Create new top-level directories ──────────────────────────────────────────
echo ""
echo "── Creating directories ──"
make_dir "$DRIVE/Games/Ubisoft"
make_dir "$DRIVE/Games/Rockstar"
make_dir "$DRIVE/Games/Standalone"
make_dir "$DRIVE/Retro/ROMs"
make_dir "$DRIVE/Retro/Emulators"
make_dir "$DRIVE/Software"
make_dir "$DRIVE/Media"

# ── Section 1: Ubisoft — root-level AC games ──────────────────────────────────
echo ""
echo "── Section 1: Ubisoft Games (root → Games/Ubisoft/) ──"
AC_ROOT_GAMES=(
  "Assassin's Creed 1"
  "Assassin's Creed II"
  "Assassin's Creed Brotherhood"
  "Assassin's Creed Revelations"
  "Assassin's Creed III Remastered"
  "Assassin's Creed IV Black Flag"
  "Assassin's Creed Rogue"
  "Assassin's Creed Unity"
  "Assassin's Creed Syndicate"
  "Assassin's Creed Origins"
  "Assassin's Creed Odyssey"
  "Assassin's Creed Chronicles China"
  "Assassin's Creed Chronicles India"
  $'Assassin\xe2\x80\x99s Creed Chronicles Russia'
  "Assassin's Creed (USA, Europe) (En,Fr,De,Es,It) (Rev 1).iso"
)
for game in "${AC_ROOT_GAMES[@]}"; do
  move_item "$DRIVE/$game" "$DRIVE/Games/Ubisoft"
done

# Ubisoft games inside Games/
TOM_CLANCY_GAMES=(
  "Splinter Cell Blacklist"
  "Splinter Cell Chaos Theory"
  "Splinter Cell Conviction"
  "Splinter Cell Double Agent"
  "Tom Clancy's Ghost Recon Wildlands"
)
for game in "${TOM_CLANCY_GAMES[@]}"; do
  move_item "$DRIVE/Games/$game" "$DRIVE/Games/Ubisoft"
done

# ── Section 2: Rockstar Games ─────────────────────────────────────────────────
echo ""
echo "── Section 2: Rockstar Games (root → Games/Rockstar/) ──"
move_item "$DRIVE/Red Dead Redemption" "$DRIVE/Games/Rockstar"

# ── Section 3: Steam ──────────────────────────────────────────────────────────
echo ""
echo "── Section 3: Steam (no move — SteamLibrary stays at G:\\SteamLibrary) ──"
echo "[INFO]  SteamLibrary left in place. Re-link via Steam > Settings > Storage if desired."

# ── Section 4: Standalone PC Games ───────────────────────────────────────────
echo ""
echo "── Section 4: Standalone PC Games (Games/ → Games/Standalone/) ──"
STANDALONE_GAMES=(
  "Call of Duty"
  "Metal Gear Solid"
  "Shenmue v1.003 (2000)(Sega)(NTSC)(US)[!]"
  "World in Conflict - Complete Edition"
)
for game in "${STANDALONE_GAMES[@]}"; do
  move_item "$DRIVE/Games/$game" "$DRIVE/Games/Standalone"
done

# ── Section 5: Retro ROMs ─────────────────────────────────────────────────────
echo ""
echo "── Section 5: Retro ROMs (Games/ → Retro/ROMs/) ──"
ROM_FOLDERS=(
  "Arcade"
  "GBA"
  "GameBoy"
  "Gamecube"
  "N64"
  "NDS"
  "NES"
  "PS1"
  "PS2"
  "PS3"
  "PSP"
  "SNES"
  "Switch"
  "Wii"
  "WiiU"
  "Xbox"
  "sgenroms"
  "Pokemon Roms"
)
for rom in "${ROM_FOLDERS[@]}"; do
  move_item "$DRIVE/Games/$rom" "$DRIVE/Retro/ROMs"
done

# ── Section 6: Emulators & Tools ──────────────────────────────────────────────
echo ""
echo "── Section 6: Emulators & Tools (Games/ → Retro/Emulators/) ──"
EMULATORS=(
  "Mesen"
  "Snes9x"
  "Retron"
  "VITAMC"
  "Switch_RCM"
)
for emu in "${EMULATORS[@]}"; do
  move_item "$DRIVE/Games/$emu" "$DRIVE/Retro/Emulators"
done

move_item "$DRIVE/Games/PKHeX (221218)"                        "$DRIVE/Retro/Emulators" "PKHeX"
move_item "$DRIVE/Games/Brew.NET.dll"                          "$DRIVE/Retro/Emulators"
move_item "$DRIVE/Games/ControlzEx.dll"                        "$DRIVE/Retro/Emulators"
move_item "$DRIVE/Games/Lunar IPS.exe"                         "$DRIVE/Retro/Emulators"
move_item "$DRIVE/Games/MahApps.Metro.dll"                     "$DRIVE/Retro/Emulators"
move_item "$DRIVE/Games/MaterialDesignColors.dll"              "$DRIVE/Retro/Emulators"
move_item "$DRIVE/Games/MaterialDesignThemes.Wpf.dll"          "$DRIVE/Retro/Emulators"
move_item "$DRIVE/Games/NSPack.exe"                            "$DRIVE/Retro/Emulators"
move_item "$DRIVE/Games/System.Windows.Interactivity.dll"      "$DRIVE/Retro/Emulators"

# ── Section 7: Software ───────────────────────────────────────────────────────
echo ""
echo "── Section 7: Software (root → Software/) ──"
move_item "$DRIVE/Wondershare"               "$DRIVE/Software"
move_item "$DRIVE/Wondershare UniConverter 17" "$DRIVE/Software"

# ── Section 8: Media ──────────────────────────────────────────────────────────
echo ""
echo "── Section 8: Media ──"
move_item "$DRIVE/Movies"                    "$DRIVE/Media"
move_item "$DRIVE/iCloud Photos.zip"         "$DRIVE/Media"
move_item "$DRIVE/iCloud Photos (1).zip"     "$DRIVE/Media"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "=========================================="
echo " Finished: $(date)"
echo " Moved:    $MOVED"
echo " Skipped:  $SKIPPED"
echo " Errors:   $ERRORS"
[[ "$DRY_RUN" == true ]] && echo " (Dry-run — no files were actually moved)"
echo "=========================================="
[[ "$ERRORS" -gt 0 ]] && exit 1 || exit 0
