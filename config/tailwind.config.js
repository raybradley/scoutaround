const { scale } = require('tailwindcss/defaultTheme')
const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*'
  ],
  theme: {
    extend: {
      dropShadow: {
        overhead: '0 0 1rem rgba(0, 0, 0, 0.1)',
      },
      boxShadow: {
        button: 'inset 0 2px 4px 0 #ffffff, inset 0 -2px 2px 0 #d6d3d1;',
        buttonactive: 'inset 0 2px 0px 0 #d6d3d1, inset 0 -2px 0px 0 #ffffff;',
        buttondark: 'inset 0 2px 0 0 #78716c, inset 0 -2px 0 0 rgb(0, 0, 0);',
        buttondarkactive: 'inset 0 3px 0 0 #0c0a09, inset 0 2px 6px 2px #78716c;',
      },
      fontFamily: {
        sans: ["Inter", ...defaultTheme.fontFamily.sans],
        serif: [...defaultTheme.fontFamily.serif],
      },
      fontSize: {
        huge: ['5rem', '1'],
      },
      colors: {
        brand: {
          100: '#F6F1E7',
          200: '#F4E1CC',
          300: '#EDAD81',
          400: '#EA7731',
          500: '#E66425',
          600: '#BC521E',
          700: '#913F17',
          800: '#4E210A',
          900: '#300F08'          
        },
        adult: {
          100: '',
          500: '',
          700: '',
        },
        youth: {
          100: '',
          500: '',
          700: '',
        },
        messages: colors.lime
      },
      listStyleType: {
        square: 'square',
      },
      maxWidth: {
        '1/2': '50%',
      },
      minWidth: {
        '96': '24rem',
      },
      animation: {
        'pop-open': 'pop-open 0.1s',
        'fade-out-after-load': 'fade-out-after-load 5s linear',
      },
      keyframes: {
        'pop-open': {
          '0%': {
            transform: 'scale(0%)'
          },
          '90%': {
            transform: 'scale(110%)'
          },
          '100%': {
            transform: 'scale(100%)'
          }
        },
        'fade-out-after-load': {
          '0%': {
            opacity: '1'
          },
          '80%': {
            opacity: '1'
          },
          '100%': {
            opacity: '0'
          }
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
