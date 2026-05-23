# WD_BLACK (G:) Drive Organization

Reorganizes the WD_BLACK external drive from a flat/scattered layout into a clean,
category-based structure grouped by application type and game launcher.

## Target Structure

```
G:\
├── Games\
│   ├── Steam\          (SteamLibrary — moved here, re-link in Steam settings)
│   ├── Ubisoft\        (Assassin's Creed series, Splinter Cell series, Ghost Recon)
│   ├── Rockstar\       (Red Dead Redemption)
│   └── Standalone\     (Call of Duty, Metal Gear Solid, Shenmue, World in Conflict)
├── Retro\
│   ├── ROMs\           (GBA, NES, SNES, N64, PS1/2/3, GameCube, Wii/WiiU, Switch, Xbox, Arcade)
│   └── Emulators\      (Mesen, Snes9x, Retron, VITAMC, Switch_RCM, PKHeX)
├── Software\           (Wondershare UniConverter)
├── Media\              (Movies, iCloud Photos archives)
├── Backup files\       (unchanged)
└── SteamLibrary\       (KEPT IN PLACE — Steam must be re-linked via Steam > Settings > Storage)
```

## Files

| File | Purpose |
|------|---------|
| `organize.sh` | Executes the reorganization on WSL (`/mnt/g/`) |
| `dry-run-plan.md` | Complete pre-execution plan listing every file move |
| `logs/` | Execution logs written during the actual run |

## Usage

```bash
# Dry run (no changes made)
bash organize.sh --dry-run

# Execute
bash organize.sh
```

## Post-Move Steps (Manual)

1. **Steam**: Open Steam → Settings → Storage → Add Folder → point to `G:\Games\Steam` → right-click each game → Move Install Folder  
   *(Or leave SteamLibrary at root — it works either way.)*
2. **Ubisoft Connect**: Launch Ubisoft Connect → locate any game → "Verify Files" → redirect to new path under `G:\Games\Ubisoft\`
3. **Rockstar Launcher**: Open Rockstar Games Launcher → Red Dead Redemption → Settings → Move game → `G:\Games\Rockstar\Red Dead Redemption`
