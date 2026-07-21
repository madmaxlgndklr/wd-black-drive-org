# Baby Log

Lightweight, mobile-first web app for tracking infant feeding and behavioral logs. Built with React, Vite, and Tailwind CSS. Designed for one-handed, low-sleep logging.

## Features

- Large, tap-friendly form for logging feeds in seconds
- Fields match a fixed schema: `date`, `time`, `caregiver`, `feeding_type`, `breast_duration_min`, `formula_oz`, `fuss_level`, `notes`
- All data stored locally in the browser (`localStorage`) — nothing leaves the device
- One-tap CSV export matching the schema column order, ready to paste into Google Sheets
- History view of recent entries with delete support for correcting mistakes

## Development

```bash
npm install
npm run dev      # local dev server
npm run build    # production build in dist/
npm run preview  # preview the production build
```

## Data schema

Each entry exported to CSV has these columns, in order:

| Column | Type | Notes |
| --- | --- | --- |
| `date` | `YYYY-MM-DD` | |
| `time` | `HH:MM` (24h) | |
| `caregiver` | text | e.g. "Max", "Tricia" |
| `feeding_type` | text | "Breast Only", "Formula Only", "Breast + Formula" |
| `breast_duration_min` | number | minutes spent nursing |
| `formula_oz` | number | ounces of formula |
| `fuss_level` | number (1-3) | 1=Calm, 2=Fussy, 3=Inconsolable/Screaming |
| `notes` | text | brief behavioral observations |

## Deploying

The app is a static site (`dist/` after `npm run build`) and can be hosted on GitHub Pages, Netlify, Vercel, or any static host.
