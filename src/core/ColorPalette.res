// Color Palette Generation Module
// Generates Tailwind-compatible color scales from base colors using Chroma.js

// External chroma-js binding
@module("chroma-js") external chroma: string => 'a = "default"
@module("chroma-js") external chromaScale: array<string> => 'a = "scale"
@send external colors: ('a, int) => array<string> = "colors"
@send external mode: ('a, string) => 'a = "mode"
@send external hex: 'a => string = "hex"

// Tailwind color scale type - matches 50-950 naming
type colorScale = {
  c50: string,
  c100: string,
  c200: string,
  c300: string,
  c400: string,
  c500: string,
  c600: string,
  c700: string,
  c800: string,
  c900: string,
  c950: string,
}

// Palette configuration
type paletteConfig = {
  baseColor: string,
  name: string,
}

// Generated palette with semantic color families
type generatedPalette = {
  primary: colorScale,
  neutral: colorScale,
  success: colorScale,
  warning: colorScale,
  error: colorScale,
  info: colorScale,
}

// Generate a single color scale from base color using Chroma.js LAB color space
let generateScale = (baseColor: string): colorScale => {
  // Create scale from white to black through the base color
  // Using LAB color space for perceptually uniform transitions
  let scale = chromaScale([
    "#ffffff",  // Very light (50)
    "#f9fafb",  // Light (100)
    "#f3f4f6",  // Light (200)
    "#e5e7eb",  // Light-medium (300)
    "#d1d5db",  // Medium-light (400)
    baseColor,  // True color (500)
    baseColor,  // Medium-dark (600) - will be darkened
    baseColor,  // Dark (700) - will be darkened more
    baseColor,  // Darker (800) - will be darkened more
    "#111827",  // Very dark (900)
    "#030712",  // Darkest (950)
  ])->mode("lab")

  let colors = scale->colors(11)
  
  {
    c50: colors[0]->Belt.Option.getWithDefault("#ffffff"),
    c100: colors[1]->Belt.Option.getWithDefault("#f9fafb"), 
    c200: colors[2]->Belt.Option.getWithDefault("#f3f4f6"),
    c300: colors[3]->Belt.Option.getWithDefault("#e5e7eb"),
    c400: colors[4]->Belt.Option.getWithDefault("#d1d5db"),
    c500: colors[5]->Belt.Option.getWithDefault(baseColor),
    c600: colors[6]->Belt.Option.getWithDefault(baseColor),
    c700: colors[7]->Belt.Option.getWithDefault(baseColor),
    c800: colors[8]->Belt.Option.getWithDefault(baseColor),
    c900: colors[9]->Belt.Option.getWithDefault("#111827"),
    c950: colors[10]->Belt.Option.getWithDefault("#030712"),
  }
}

// Create full palette from configuration
let createPalette = (config: paletteConfig): generatedPalette => {
  let primaryScale = generateScale(config.baseColor)
  
  // Generate semantic color scales
  let neutralScale = generateScale("#6b7280")  // Gray-500 equivalent
  let successScale = generateScale("#059669")  // Green-600 equivalent  
  let warningScale = generateScale("#d97706")  // Amber-600 equivalent
  let errorScale = generateScale("#dc2626")    // Red-600 equivalent
  let infoScale = generateScale("#2563eb")     // Blue-600 equivalent
  
  {
    primary: primaryScale,
    neutral: neutralScale,
    success: successScale,
    warning: warningScale,
    error: errorScale,
    info: infoScale,
  }
}

// Default palette configuration
let defaultPalette = createPalette({
  baseColor: "#3b82f6", // Blue-500 equivalent
  name: "default",
})

// Utility to get color from scale by intensity
type colorIntensity = 
  | C50 | C100 | C200 | C300 | C400 | C500 
  | C600 | C700 | C800 | C900 | C950

let getColorFromScale = (scale: colorScale, intensity: colorIntensity): string => {
  switch intensity {
  | C50 => scale.c50
  | C100 => scale.c100
  | C200 => scale.c200
  | C300 => scale.c300
  | C400 => scale.c400
  | C500 => scale.c500
  | C600 => scale.c600
  | C700 => scale.c700
  | C800 => scale.c800
  | C900 => scale.c900
  | C950 => scale.c950
  }
}