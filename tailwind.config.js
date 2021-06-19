const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  purge: [],
  darkMode: false, // or 'media' or 'class'
  theme: {
    maxHeight: {
      'screen': '90vh',
    },
    extend: {},
  },
  variants: {
    extend: {
      opacity: ['disabled']
    }
  },
  plugins: [],
}

