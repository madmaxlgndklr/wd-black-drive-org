/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        calm: '#22c55e',
        fussy: '#f59e0b',
        inconsolable: '#ef4444',
      },
    },
  },
  plugins: [],
}
