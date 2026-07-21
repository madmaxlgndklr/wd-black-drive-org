import { formatTime12h, formatDateShort } from '../utils/datetime.js'

const FUSS_META = {
  1: { emoji: '😌', label: 'Calm', classes: 'bg-emerald-100 text-emerald-700' },
  2: { emoji: '😣', label: 'Fussy', classes: 'bg-amber-100 text-amber-700' },
  3: { emoji: '😭', label: 'Inconsolable', classes: 'bg-red-100 text-red-700' },
}

export default function EntryCard({ entry, onDelete }) {
  const fuss = FUSS_META[entry.fuss_level] || FUSS_META[1]

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
      <div className="flex items-start justify-between gap-2">
        <div>
          <div className="text-sm font-bold text-slate-800">
            {formatDateShort(entry.date)} · {formatTime12h(entry.time)}
          </div>
          <div className="text-xs text-slate-500">{entry.caregiver}</div>
        </div>
        <div className="flex items-center gap-2">
          <span className={`rounded-full px-2 py-1 text-xs font-bold ${fuss.classes}`}>
            {fuss.emoji} {fuss.label}
          </span>
          <button
            type="button"
            onClick={() => onDelete(entry.id)}
            aria-label="Delete entry"
            className="text-slate-300 active:text-red-500 text-lg leading-none px-1"
          >
            ✕
          </button>
        </div>
      </div>

      <div className="mt-2 flex flex-wrap items-center gap-2 text-sm">
        <span className="rounded-full bg-sky-100 text-sky-700 px-2 py-1 font-semibold">
          {entry.feeding_type}
        </span>
        {entry.breast_duration_min > 0 && (
          <span className="text-slate-600">🤱 {entry.breast_duration_min} min</span>
        )}
        {entry.formula_oz > 0 && <span className="text-slate-600">🍼 {entry.formula_oz} oz</span>}
      </div>

      {entry.notes && <p className="mt-2 text-sm text-slate-600 italic">"{entry.notes}"</p>}
    </div>
  )
}
