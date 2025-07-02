export default {
  content: [
    './src/components/**/*.res',
    './src/layouts/**/*.res',
    './src/*.res',
  ],
  safelist: [
    // Design system spacing classes that are generated dynamically
    // All spacing values from TailwindTypes.res
    { pattern: /^(m|p)(t|b|l|r|x|y)?-(0|1|2|3|4|5|6|8|10|12|16|20|24|32|40|48|64)$/ },
    // Text sizes from design system
    { pattern: /^text-(xs|sm|base|lg|xl|2xl|3xl|4xl|5xl|6xl)$/ },
    // Font weights from design system  
    { pattern: /^font-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)$/ },
    // Design system color patterns - covers all color utilities used in DesignSystem.res
    { pattern: /^(text|bg|border)-neutral-/ },
    { pattern: /^(text|bg|border)-green-/ },
    { pattern: /^(text|bg|border)-amber-/ },
    { pattern: /^(text|bg|border)-red-/ },
    { pattern: /^(text|bg|border)-blue-/ },
    { pattern: /^(text|bg|border)-gray-/ },
    // Generated color arbitrary values - Tailwind's [#hexcode] syntax
    { pattern: /^(text|bg|border)-\[#[0-9a-fA-F]{6}\]/ },
    // Base colors
    'text-white',
    'bg-transparent',
  ],
  theme: {
    extend: {
      colors: {
        surface: {
          DEFAULT: '#FFFFFF',   // primary white surface
          subtle: '#F7F7F7',   // subtle off-white surface
        },
        text: {
          primary: '#111111',   // high-contrast body text
          secondary: '#555555', // muted secondary text
        },
        accent: {
          DEFAULT: '#111111',   // black accent for CTAs
        },
      },
      borderRadius: {
        none: '0px',
        sm: '2px',
      },
      fontFamily: {
        sans: ['Inter', 'SF Pro Text', 'Helvetica Neue', 'Arial', 'sans-serif'],
      },
    },
    /* Most of the time we customize the font-sizes,
     so we added the Tailwind default values here for
     convenience */
    fontSize: {
      xs: ".75rem",
      sm: ".875rem",
      base: "1rem",
      lg: "1.125rem",
      xl: "1.25rem",
      '2xl': "1.5rem",
      '3xl': "1.875rem",
      '4xl': "2.25rem",
      '5xl': "3rem",
      '6xl': "4rem"
    },
    /* We override the default font-families with our own default prefs  */
    fontFamily: {
      'sans': ['Inter', 'SF Pro Text', 'Helvetica Neue', 'Arial', 'sans-serif'],
      'serif': ['Georgia', 'Times', 'Times New Roman', 'serif'],
      'mono': ['Menlo', 'Monaco', 'Consolas', 'SFMono-Regular', 'monospace']
    },
  },
  variants: {
    width: ['responsive']
  },
  plugins: []
}
