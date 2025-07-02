/* CoreTypes – centralised type definitions for ReScript marketing site */

// Base UI types
type color = string
type size = Small | Medium | Large
type variant = Primary | Secondary | Success | Warning | Error | Info

// Theme types
type themeMode = Light | Dark | System

// Form types  
type inputType = Text | Email | Password | Number | Search | Tel | Url

// Generic API envelope
type apiError = {message: string, code: option<int>, details: option<Js.Json.t>}
type apiResponse<'a> = result<'a, apiError>

// Advanced color types for palette generation
module Color = {
  // Re-export from ColorTheory module for convenience
  type rgb = ColorTheory.rgb
  type hsl = ColorTheory.hsl
  type hsv = ColorTheory.hsv
  type lab = ColorTheory.lab
  type t = ColorTheory.color
  
  // Palette-specific types
  type colorScale = array<PaletteGenerator.colorScaleEntry>
  type palette = PaletteGenerator.palette
  type paletteMode = [#monochromatic | #analogous | #complementary | #triadic | #custom]
  
  // Color token types for design system
  type colorToken = {
    name: string,
    value: t,
    description: option<string>,
  }
  
  type colorTokenGroup = {
    name: string,
    tokens: array<colorToken>,
  }
  
  // Theme-aware color type
  type themedColor = {
    light: t,
    dark: t,
    highContrast: option<t>,
    reducedMotion: option<t>,
  }
}