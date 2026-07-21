const COLUMNS = [
  'date',
  'time',
  'caregiver',
  'feeding_type',
  'breast_duration_min',
  'formula_oz',
  'fuss_level',
  'notes',
]

function escapeCsvField(value) {
  const str = value === undefined || value === null ? '' : String(value)
  if (/[",\n]/.test(str)) {
    return `"${str.replace(/"/g, '""')}"`
  }
  return str
}

export function entriesToCsv(entries) {
  const header = COLUMNS.join(',')
  const rows = entries.map((entry) =>
    COLUMNS.map((col) => escapeCsvField(entry[col])).join(','),
  )
  return [header, ...rows].join('\n')
}

export function downloadCsv(entries, filename = 'infant-feeding-log.csv') {
  const csv = entriesToCsv(entries)
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}
