import { useEffect, useMemo, useState } from 'react'
import LogForm from './components/LogForm.jsx'
import EntryList from './components/EntryList.jsx'
import { loadEntries, saveEntries } from './utils/storage.js'
import { downloadCsv } from './utils/csv.js'

const DEFAULT_CAREGIVERS = ['Max', 'Tricia']

function makeId() {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
}

export default function App() {
  const [entries, setEntries] = useState(() => loadEntries())
  const [tab, setTab] = useState('log')

  useEffect(() => {
    saveEntries(entries)
  }, [entries])

  const sortedEntries = useMemo(
    () =>
      [...entries].sort((a, b) => {
        const aKey = `${a.date}T${a.time}`
        const bKey = `${b.date}T${b.time}`
        if (aKey !== bKey) return aKey < bKey ? 1 : -1
        return (b.createdAt || 0) - (a.createdAt || 0)
      }),
    [entries],
  )

  const caregivers = useMemo(() => {
    const seen = new Set(DEFAULT_CAREGIVERS)
    const extra = []
    for (const e of entries) {
      if (!seen.has(e.caregiver)) {
        seen.add(e.caregiver)
        extra.push(e.caregiver)
      }
    }
    return [...DEFAULT_CAREGIVERS, ...extra]
  }, [entries])

  const lastCaregiver = sortedEntries[0]?.caregiver

  const handleSave = (entry) => {
    setEntries((prev) => [...prev, { ...entry, id: makeId(), createdAt: Date.now() }])
    setTab('log')
  }

  const handleDelete = (id) => {
    if (!confirm('Delete this entry?')) return
    setEntries((prev) => prev.filter((e) => e.id !== id))
  }

  const handleExport = () => {
    if (entries.length === 0) {
      alert('No entries to export yet.')
      return
    }
    const dateStamp = new Date().toISOString().slice(0, 10)
    downloadCsv(sortedEntries, `infant-feeding-log-${dateStamp}.csv`)
  }

  return (
    <div className="min-h-screen bg-slate-50 pb-24">
      <header className="sticky top-0 z-10 bg-sky-500 text-white px-4 pt-[env(safe-area-inset-top)] pb-3 shadow-md">
        <div className="pt-3 flex items-center justify-between">
          <h1 className="text-xl font-extrabold">🍼 Baby Log</h1>
          <button
            type="button"
            onClick={handleExport}
            className="rounded-lg bg-white/20 px-3 py-2 text-sm font-bold active:bg-white/30"
          >
            Export CSV
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-md px-4 pt-4">
        {tab === 'log' ? (
          <LogForm onSave={handleSave} caregivers={caregivers} lastCaregiver={lastCaregiver} />
        ) : (
          <EntryList entries={sortedEntries} onDelete={handleDelete} />
        )}
      </main>

      <nav className="fixed bottom-0 inset-x-0 z-10 bg-white border-t border-slate-200 pb-[env(safe-area-inset-bottom)]">
        <div className="mx-auto max-w-md grid grid-cols-2">
          <button
            type="button"
            onClick={() => setTab('log')}
            className={`py-4 text-center font-bold text-sm ${
              tab === 'log' ? 'text-sky-600' : 'text-slate-400'
            }`}
          >
            ➕ Log Feed
          </button>
          <button
            type="button"
            onClick={() => setTab('history')}
            className={`py-4 text-center font-bold text-sm ${
              tab === 'history' ? 'text-sky-600' : 'text-slate-400'
            }`}
          >
            📋 History ({entries.length})
          </button>
        </div>
      </nav>
    </div>
  )
}
