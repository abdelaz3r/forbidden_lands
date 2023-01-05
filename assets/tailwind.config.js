// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
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
      'none': "0 0 #0000"
    },
    extend: {
      fontFamily: {
        title: ['Lora']
      },
      colors: {
        brand: "#FD4F00",
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