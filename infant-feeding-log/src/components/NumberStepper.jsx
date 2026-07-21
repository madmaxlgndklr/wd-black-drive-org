export default function NumberStepper({ label, value, onChange, step = 1, min = 0, max = 999, unit }) {
  const clamp = (n) => Math.min(max, Math.max(min, n))

  const handleChange = (e) => {
    const raw = e.target.value
    if (raw === '') {
      onChange('')
      return
    }
    const n = Number(raw)
    if (!Number.isNaN(n)) onChange(clamp(n))
  }

  return (
    <div>
      <label className="block text-sm font-semibold text-slate-600 mb-2">{label}</label>
      <div className="flex items-stretch gap-2">
        <button
          type="button"
          onClick={() => onChange(clamp((Number(value) || 0) - step))}
          className="w-14 shrink-0 rounded-xl bg-slate-200 text-slate-700 text-2xl font-bold active:bg-slate-300 active:scale-95 transition"
          aria-label={`Decrease ${label}`}
        >
          −
        </button>
        <div className="flex-1 relative">
          <input
            type="number"
            inputMode="decimal"
            value={value}
            onChange={handleChange}
            className="w-full h-full rounded-xl border-2 border-slate-200 text-center text-xl font-bold py-3 focus:border-sky-400 focus:outline-none"
          />
          {unit && (
            <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-sm text-slate-400">
              {unit}
            </span>
          )}
        </div>
        <button
          type="button"
          onClick={() => onChange(clamp((Number(value) || 0) + step))}
          className="w-14 shrink-0 rounded-xl bg-slate-200 text-slate-700 text-2xl font-bold active:bg-slate-300 active:scale-95 transition"
          aria-label={`Increase ${label}`}
        >
          +
        </button>
      </div>
    </div>
  )
}
