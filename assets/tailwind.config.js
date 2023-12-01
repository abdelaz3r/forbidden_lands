// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  safelist: [
    'font-bold',
    'text-xl',
    'list-disc',
    'list-inside'
  ],
  theme: {
    boxShadow: {
      'sm': "0 0 2px 0 rgb(0 0 0 / 0.05)",
      'DEFAULT': "0 0 3px 0 rgb(0 0 0 / 0.1), 0 0 2px 0 rgb(0 0 0 / 0.1)",
      'md': "0 0 6px 0 rgb(0 0 0 / 0.1), 0 0 4px 0 rgb(0 0 0 / 0.1)",
      'lg': "0 0 15px 0 rgb(0 0 0 / 0.1), 0 0 6px 0 rgb(0 0 0 / 0.1)",
      'xl': "0 0 25px 0 rgb(0 0 0 / 0.1), 0 0 10px 0 rgb(0 0 0 / 0.1)",
      '2xl': "0 0 50px 0 rgb(0 0 0 / 0.25)",
      'inner': "inset 0 2px 4px 0 rgb(0 0 0 / 0.05)",
      'daylight': "inset 0 0 20px 10px rgba(0, 0, 0, 0.3)",
      'ligthish': "inset 0 0 30px 15px rgba(0, 0, 0, 0.4)",
      'darkish': "inset 0 0 40px 20px rgba(0, 0, 0, 0.5)",
      'dark': "inset 0 0 60px 30px rgba(0, 0, 0, 0.6)",
      'none': "0 0 #0000"
    },
    extend: {
      fontFamily: {
        sans: ['"Open Sans"', ...defaultTheme.fontFamily.sans],
        serif: ['Lora', ...defaultTheme.fontFamily.serif],
        'spell-title': ['Satisfy', ...defaultTheme.fontFamily.serif],
        'spell-body': ['"Crimson Pro"', ...defaultTheme.fontFamily.serif],
      },
      colors: {
        brand: "#FD4F00"
      },
      spacing: {
        '13': '3.25rem'
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))
  ]
}