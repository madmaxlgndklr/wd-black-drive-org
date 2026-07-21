import { useState } from 'react'
import EntryCard from './EntryCard.jsx'

export default function EntryList({ entries, onDelete }) {
  const [showAll, setShowAll] = useState(false)
  const visible = showAll ? entries : entries.slice(0, 10)

  if (entries.length === 0) {
    return (
      <div className="rounded-2xl border-2 border-dashed border-slate-200 py-10 text-center text-slate-400">
        No entries yet. Log the first feed above.
      </div>
    )
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">
          Recent Entries ({entries.length} total)
        </h2>
      </div>
      {visible.map((entry) => (
        <EntryCard key={entry.id} entry={entry} onDelete={onDelete} />
      ))}
      {entries.length > 10 && (
        <button
          type="button"
          onClick={() => setShowAll((s) => !s)}
          className="w-full rounded-xl bg-slate-100 text-slate-600 font-semibold py-3 active:bg-slate-200"
        >
          {showAll ? 'Show fewer' : `Show all ${entries.length} entries`}
        </button>
      )}
    </div>
  )
}
