import { useState } from 'react'
import NumberStepper from './NumberStepper.jsx'
import { todayDateStr, nowTimeStr } from '../utils/datetime.js'

const FEEDING_TYPES = ['Breast Only', 'Formula Only', 'Breast + Formula']

const FUSS_LEVELS = [
  { value: 1, label: 'Calm', emoji: '😌', classes: 'bg-emerald-500 border-emerald-600' },
  { value: 2, label: 'Fussy', emoji: '😣', classes: 'bg-amber-500 border-amber-600' },
  { value: 3, label: 'Inconsolable', emoji: '😭', classes: 'bg-red-500 border-red-600' },
]

function emptyForm(defaultCaregiver) {
  return {
    date: todayDateStr(),
    time: nowTimeStr(),
    caregiver: defaultCaregiver || '',
    feeding_type: 'Breast Only',
    breast_duration_min: 0,
    formula_oz: 0,
    fuss_level: 1,
    notes: '',
  }
}

export default function LogForm({ onSave, caregivers, lastCaregiver }) {
  const [form, setForm] = useState(() => emptyForm(lastCaregiver))
  const [customCaregiver, setCustomCaregiver] = useState(false)

  const update = (field, value) => setForm((f) => ({ ...f, [field]: value }))

  const showBreast = form.feeding_type !== 'Formula Only'
  const showFormula = form.feeding_type !== 'Breast Only'

  const handleSubmit = (e) => {
    e.preventDefault()
    if (!form.caregiver.trim()) {
      alert('Please select or enter a caregiver.')
      return
    }
    const entry = {
      date: form.date,
      time: form.time,
      caregiver: form.caregiver.trim(),
      feeding_type: form.feeding_type,
      breast_duration_min: showBreast ? Number(form.breast_duration_min) || 0 : 0,
      formula_oz: showFormula ? Number(form.formula_oz) || 0 : 0,
      fuss_level: form.fuss_level,
      notes: form.notes.trim(),
    }
    onSave(entry)
    setForm(emptyForm(entry.caregiver))
    setCustomCaregiver(false)
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5">
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-semibold text-slate-600 mb-2">Date</label>
          <input
            type="date"
            value={form.date}
            onChange={(e) => update('date', e.target.value)}
            className="w-full rounded-xl border-2 border-slate-200 py-3 px-3 text-lg font-medium focus:border-sky-400 focus:outline-none"
            required
          />
        </div>
        <div>
          <label className="block text-sm font-semibold text-slate-600 mb-2">Time</label>
          <input
            type="time"
            value={form.time}
            onChange={(e) => update('time', e.target.value)}
            className="w-full rounded-xl border-2 border-slate-200 py-3 px-3 text-lg font-medium focus:border-sky-400 focus:outline-none"
            required
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-semibold text-slate-600 mb-2">Caregiver</label>
        {!customCaregiver ? (
          <div className="flex flex-wrap gap-2">
            {caregivers.map((c) => (
              <button
                key={c}
                type="button"
                onClick={() => update('caregiver', c)}
                className={`flex-1 min-w-[45%] rounded-xl py-3 text-lg font-bold border-2 active:scale-95 transition ${
                  form.caregiver === c
                    ? 'bg-sky-500 border-sky-600 text-white'
                    : 'bg-white border-slate-200 text-slate-700'
                }`}
              >
                {c}
              </button>
            ))}
            <button
              type="button"
              onClick={() => {
                setCustomCaregiver(true)
                update('caregiver', '')
              }}
              className="flex-1 min-w-[45%] rounded-xl py-3 text-lg font-bold border-2 border-dashed border-slate-300 text-slate-500 active:scale-95 transition"
            >
              + Other
            </button>
          </div>
        ) : (
          <div className="flex gap-2">
            <input
              type="text"
              autoFocus
              value={form.caregiver}
              onChange={(e) => update('caregiver', e.target.value)}
              placeholder="Enter name"
              className="flex-1 rounded-xl border-2 border-slate-200 py-3 px-3 text-lg font-medium focus:border-sky-400 focus:outline-none"
            />
            <button
              type="button"
              onClick={() => setCustomCaregiver(false)}
              className="rounded-xl px-4 bg-slate-200 text-slate-600 font-bold"
            >
              Back
            </button>
          </div>
        )}
      </div>

      <div>
        <label className="block text-sm font-semibold text-slate-600 mb-2">Feeding Type</label>
        <div className="grid grid-cols-1 gap-2">
          {FEEDING_TYPES.map((type) => (
            <button
              key={type}
              type="button"
              onClick={() => update('feeding_type', type)}
              className={`rounded-xl py-3 px-4 text-lg font-bold border-2 text-left active:scale-95 transition ${
                form.feeding_type === type
                  ? 'bg-sky-500 border-sky-600 text-white'
                  : 'bg-white border-slate-200 text-slate-700'
              }`}
            >
              {type}
            </button>
          ))}
        </div>
      </div>

      {showBreast && (
        <NumberStepper
          label="Breast Duration"
          value={form.breast_duration_min}
          onChange={(v) => update('breast_duration_min', v)}
          step={1}
          min={0}
          max={180}
          unit="min"
        />
      )}

      {showFormula && (
        <NumberStepper
          label="Formula Amount"
          value={form.formula_oz}
          onChange={(v) => update('formula_oz', v)}
          step={0.5}
          min={0}
          max={20}
          unit="oz"
        />
      )}

      <div>
        <label className="block text-sm font-semibold text-slate-600 mb-2">Fuss Level</label>
        <div className="grid grid-cols-3 gap-2">
          {FUSS_LEVELS.map((lvl) => (
            <button
              key={lvl.value}
              type="button"
              onClick={() => update('fuss_level', lvl.value)}
              className={`rounded-xl py-4 border-2 flex flex-col items-center gap-1 active:scale-95 transition ${
                form.fuss_level === lvl.value
                  ? `${lvl.classes} text-white`
                  : 'bg-white border-slate-200 text-slate-600'
              }`}
            >
              <span className="text-2xl">{lvl.emoji}</span>
              <span className="text-xs font-bold">{lvl.label}</span>
            </button>
          ))}
        </div>
      </div>

      <div>
        <label className="block text-sm font-semibold text-slate-600 mb-2">Notes</label>
        <textarea
          value={form.notes}
          onChange={(e) => update('notes', e.target.value)}
          placeholder="Cried at breast, took 3oz formula immediately after..."
          rows={3}
          className="w-full rounded-xl border-2 border-slate-200 py-3 px-3 text-base focus:border-sky-400 focus:outline-none resize-none"
        />
      </div>

      <button
        type="submit"
        className="w-full rounded-2xl bg-sky-500 text-white text-xl font-extrabold py-5 shadow-lg shadow-sky-500/30 active:scale-95 active:bg-sky-600 transition"
      >
        Log Entry
      </button>
    </form>
  )
}
