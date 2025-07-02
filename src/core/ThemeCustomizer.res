// Theme Customizer - Integrates palette generation with existing theme system
// Allows dynamic theme creation from brand colors using color theory

module CT = ColorTheory
module PG = PaletteGenerator
module Themes = Themes

// Color configuration type
type baseColors = {
  primary: CT.color,
  secondary: option<CT.color>,
  accent: option<CT.color>,
}

// Scale weight configuration type  
type scaleWeights = {
  primary: int,    // Which weight to use for primary actions (default: 600)
  secondary: int,  // Which weight to use for secondary actions (default: 500)
  muted: int,      // Which weight to use for muted elements (default: 400)
}

// Enhanced theme configuration with palette support
type paletteThemeConfig = {
  baseColors: baseColors,
  palette: PG.palette,
  mode: Themes.theme,
  semanticOverrides: option<Map.t<DesignSystem.color, CT.color>>,
  scaleWeights: scaleWeights,
}

// Default scale weights for consistent usage
let defaultScaleWeights: scaleWeights = {
  primary: 600,
  secondary: 500,
  muted: 400,
}

// Create a custom theme from a brand color
let createPaletteTheme = (
  ~brandColor: CT.color,
  ~generationMode: [#corporate | #vibrant | #balanced | #minimal]=#corporate,
  ~baseTheme: Themes.theme=Light,
  ~secondaryColor: option<CT.color>=?,
  ~accentColor: option<CT.color>=?,
  ~scaleWeights: scaleWeights=defaultScaleWeights,
  ()
): paletteThemeConfig => {
  // Generate the main palette from brand color
  let palette = switch generationMode {
  | #corporate => PG.Presets.corporate(brandColor)
  | #vibrant => PG.Presets.vibrant(brandColor) 
  | #balanced => PG.Presets.balanced(brandColor)
  | #minimal => PG.Presets.minimal(brandColor)
  }
  
  {
    baseColors: {
      primary: brandColor,
      secondary: secondaryColor,
      accent: accentColor,
    },
    palette,
    mode: baseTheme,
    semanticOverrides: None,
    scaleWeights,
  }
}

// Find palette entry by weight
let findScaleEntry = (palette: PG.palette, weight: int): option<PG.colorScaleEntry> => {
  palette.scale->Array.find(entry => entry.weight == weight)
}

// Get color from palette with fallback
let getScaleColor = (palette: PG.palette, weight: int, fallback: string): string => {
  switch findScaleEntry(palette, weight) {
  | Some(entry) => entry.hex
  | None => fallback
  }
}

// Enhanced color resolution using generated palettes
let resolvePaletteColor = (
  color: DesignSystem.color, 
  config: paletteThemeConfig
): string => {
  let {palette, mode, semanticOverrides, scaleWeights} = config
  
  // Check for manual overrides first
  let overrideColor = switch semanticOverrides {
  | Some(overrides) => overrides->Map.get(color)
  | None => None
  }
  
  switch overrideColor {
  | Some(customColor) => CT.Convert.toHex(customColor)
  | None => {
    // Use generated palette colors
    switch (color, mode) {
    // Primary colors use brand palette
    | (Primary, Light) => getScaleColor(palette, scaleWeights.primary, "#1f2937")
    | (Primary, Dark) => getScaleColor(palette, 400, "#f9fafb")
    | (Primary, HighContrast) => getScaleColor(palette, 900, "#000000")
    | (Primary, ReducedMotion) => getScaleColor(palette, scaleWeights.primary, "#1f2937")
    | (Primary, Sepia) => getScaleColor(palette, 700, "#92400e")
    
    // Secondary colors use lighter weights
    | (Secondary, Light) => getScaleColor(palette, scaleWeights.secondary, "#374151")
    | (Secondary, Dark) => getScaleColor(palette, 300, "#d1d5db")
    | (Secondary, HighContrast) => getScaleColor(palette, 800, "#1f2937")
    | (Secondary, ReducedMotion) => getScaleColor(palette, scaleWeights.secondary, "#374151")
    | (Secondary, Sepia) => getScaleColor(palette, 600, "#b45309")
    
    // Tertiary colors use even lighter weights
    | (Tertiary, Light) => getScaleColor(palette, scaleWeights.muted, "#6b7280")
    | (Tertiary, Dark) => getScaleColor(palette, 400, "#9ca3af")
    | (Tertiary, HighContrast) => getScaleColor(palette, 700, "#374151")
    | (Tertiary, ReducedMotion) => getScaleColor(palette, scaleWeights.muted, "#6b7280")
    | (Tertiary, Sepia) => getScaleColor(palette, 500, "#d97706")
    
    // Muted colors use lightest weights
    | (Muted, Light) => getScaleColor(palette, 300, "#d1d5db")
    | (Muted, Dark) => getScaleColor(palette, 600, "#4b5563")
    | (Muted, HighContrast) => getScaleColor(palette, 600, "#4b5563")
    | (Muted, ReducedMotion) => getScaleColor(palette, 300, "#d1d5db")
    | (Muted, Sepia) => getScaleColor(palette, 400, "#f59e0b")
    
    // Inverse colors use opposite ends of the scale
    | (Inverse, Light) => getScaleColor(palette, 900, "#111827")
    | (Inverse, Dark) => getScaleColor(palette, 50, "#f9fafb")
    | (Inverse, HighContrast) => getScaleColor(palette, 50, "#ffffff")
    | (Inverse, ReducedMotion) => getScaleColor(palette, 900, "#111827")
    | (Inverse, Sepia) => getScaleColor(palette, 100, "#fef3c7")
    
    // Semantic colors use generated semantic palette if available
    | (Success, _) => switch palette.semanticColors {
      | Some(semantic) => CT.Convert.toHex(semantic.success)
      | None => "#059669" // fallback green
      }
    | (Warning, _) => switch palette.semanticColors {
      | Some(semantic) => CT.Convert.toHex(semantic.warning)
      | None => "#d97706" // fallback amber
      }
    | (Error, _) => switch palette.semanticColors {
      | Some(semantic) => CT.Convert.toHex(semantic.error)
      | None => "#dc2626" // fallback red
      }
    | (Info, _) => switch palette.semanticColors {
      | Some(semantic) => CT.Convert.toHex(semantic.info)
      | None => "#2563eb" // fallback blue
      }
    }
  }
  }
}

// Enhanced background color resolution 
let resolvePaletteBackgroundColor = (
  color: DesignSystem.color,
  config: paletteThemeConfig
): string => {
  let {palette, mode} = config
  
  switch (color, mode) {
  // Primary backgrounds
  | (Primary, Light) => getScaleColor(palette, 50, "#ffffff")
  | (Primary, Dark) => getScaleColor(palette, 900, "#111827")
  | (Primary, HighContrast) => getScaleColor(palette, 50, "#ffffff")
  | (Primary, ReducedMotion) => getScaleColor(palette, 50, "#ffffff")
  | (Primary, Sepia) => getScaleColor(palette, 50, "#fffbeb")
  
  // Secondary backgrounds
  | (Secondary, Light) => getScaleColor(palette, 100, "#f3f4f6")
  | (Secondary, Dark) => getScaleColor(palette, 800, "#1f2937")
  | (Secondary, HighContrast) => getScaleColor(palette, 100, "#f3f4f6")
  | (Secondary, ReducedMotion) => getScaleColor(palette, 100, "#f3f4f6")
  | (Secondary, Sepia) => getScaleColor(palette, 100, "#fef3c7")
  
  // Tertiary backgrounds
  | (Tertiary, Light) => getScaleColor(palette, 200, "#e5e7eb")
  | (Tertiary, Dark) => getScaleColor(palette, 700, "#374151")
  | (Tertiary, HighContrast) => getScaleColor(palette, 200, "#e5e7eb")
  | (Tertiary, ReducedMotion) => getScaleColor(palette, 200, "#e5e7eb")
  | (Tertiary, Sepia) => getScaleColor(palette, 200, "#fde68a")
  
  // Muted backgrounds
  | (Muted, Light) => getScaleColor(palette, 300, "#d1d5db")
  | (Muted, Dark) => getScaleColor(palette, 600, "#4b5563")
  | (Muted, HighContrast) => getScaleColor(palette, 300, "#d1d5db")
  | (Muted, ReducedMotion) => getScaleColor(palette, 300, "#d1d5db")
  | (Muted, Sepia) => getScaleColor(palette, 300, "#fcd34d")
  
  // Inverse backgrounds
  | (Inverse, Light) => getScaleColor(palette, 900, "#111827")
  | (Inverse, Dark) => getScaleColor(palette, 50, "#f9fafb")
  | (Inverse, HighContrast) => getScaleColor(palette, 900, "#000000")
  | (Inverse, ReducedMotion) => getScaleColor(palette, 900, "#111827")
  | (Inverse, Sepia) => getScaleColor(palette, 800, "#92400e")
  
  | _ => "transparent" // fallback for status colors
  }
}

// Enhanced border color resolution
let resolvePaletteBorderColor = (
  color: DesignSystem.color,
  config: paletteThemeConfig
): string => {
  let {palette, mode} = config
  
  switch (color, mode) {
  | (Primary, Light) => getScaleColor(palette, 300, "#d1d5db")
  | (Primary, Dark) => getScaleColor(palette, 600, "#4b5563")
  | (Primary, HighContrast) => getScaleColor(palette, 900, "#000000")
  | (Primary, ReducedMotion) => getScaleColor(palette, 300, "#d1d5db")
  | (Primary, Sepia) => getScaleColor(palette, 300, "#fcd34d")
  | _ => "transparent"
  }
}

// Generate CSS classes for palette-based colors
let toPaletteClass = (color: DesignSystem.color, config: paletteThemeConfig, property: [#text | #bg | #border]): string => {
  let hex = switch property {
  | #text => resolvePaletteColor(color, config)
  | #bg => resolvePaletteBackgroundColor(color, config)
  | #border => resolvePaletteBorderColor(color, config)
  }
  
  let prefix = switch property {
  | #text => "text-"
  | #bg => "bg-"
  | #border => "border-"
  }
  
  // Return arbitrary value class for Tailwind
  `${prefix}[${hex}]`
}

// Enhanced themed style helpers that use palette colors
type paletteThemedStyle = {
  resolveColor: DesignSystem.color => string,
  resolveBackground: DesignSystem.color => string,
  resolveBorder: DesignSystem.color => string,
  getColorClass: DesignSystem.color => string,
  getBackgroundClass: DesignSystem.color => string,
  getBorderClass: DesignSystem.color => string,
  palette: PG.palette,
  config: paletteThemeConfig,
}

// Create themed style helpers with palette support
let createPaletteThemedStyle = (config: paletteThemeConfig): paletteThemedStyle => {
  {
    resolveColor: color => resolvePaletteColor(color, config),
    resolveBackground: color => resolvePaletteBackgroundColor(color, config),
    resolveBorder: color => resolvePaletteBorderColor(color, config),
    getColorClass: color => toPaletteClass(color, config, #text),
    getBackgroundClass: color => toPaletteClass(color, config, #bg),
    getBorderClass: color => toPaletteClass(color, config, #border),
    palette: config.palette,
    config,
  }
}

// Theme preset factory functions
module Presets = {
  // Corporate theme with professional blue palette
  let corporate = (~brandColor: option<CT.color>=?, ~baseTheme: Themes.theme=Light, ()): paletteThemeConfig => {
    let defaultColor = CT.RGB({r: 37.0, g: 99.0, b: 235.0})
    let color = brandColor->Option.getOr(defaultColor)
    createPaletteTheme(~brandColor=color, ~generationMode=#corporate, ~baseTheme, ())
  }
  
  // Vibrant theme with rich, colorful palette
  let vibrant = (~brandColor: option<CT.color>=?, ~baseTheme: Themes.theme=Light, ()): paletteThemeConfig => {
    let defaultColor = CT.RGB({r: 239.0, g: 68.0, b: 68.0})
    let color = brandColor->Option.getOr(defaultColor)
    createPaletteTheme(~brandColor=color, ~generationMode=#vibrant, ~baseTheme, ())
  }
  
  // Balanced theme with complementary harmony
  let balanced = (~brandColor: option<CT.color>=?, ~baseTheme: Themes.theme=Light, ()): paletteThemeConfig => {
    let defaultColor = CT.RGB({r: 5.0, g: 150.0, b: 105.0})
    let color = brandColor->Option.getOr(defaultColor)
    createPaletteTheme(~brandColor=color, ~generationMode=#balanced, ~baseTheme, ())
  }
  
  // Minimal theme with simple color palette
  let minimal = (~brandColor: option<CT.color>=?, ~baseTheme: Themes.theme=Light, ()): paletteThemeConfig => {
    let defaultColor = CT.RGB({r: 107.0, g: 114.0, b: 128.0})
    let color = brandColor->Option.getOr(defaultColor)
    createPaletteTheme(~brandColor=color, ~generationMode=#minimal, ~baseTheme, ())
  }
}

// Export utilities for theme configuration generation
module Export = {
  // Generate Tailwind config from theme configuration
  let toTailwindConfig = (config: paletteThemeConfig, themeName: string): string => {
    PG.Utils.toTailwindConfig(config.palette, themeName)
  }
  
  // Generate CSS custom properties from theme configuration
  let toCssVariables = (config: paletteThemeConfig, themeName: string): string => {
    PG.Utils.toCssVariables(config.palette, themeName)
  }
  
  // Generate complete theme export including semantic mappings
  let toThemeExport = (config: paletteThemeConfig, themeName: string): string => {
    let paletteExport = PG.Utils.toCssVariables(config.palette, themeName)
    let semanticMappings = `
/* Semantic color mappings for ${themeName} */
:root[data-theme="${themeName}"] {
  --color-primary: ${resolvePaletteColor(Primary, config)};
  --color-secondary: ${resolvePaletteColor(Secondary, config)};
  --color-tertiary: ${resolvePaletteColor(Tertiary, config)};
  --color-muted: ${resolvePaletteColor(Muted, config)};
  --color-inverse: ${resolvePaletteColor(Inverse, config)};
  --color-success: ${resolvePaletteColor(Success, config)};
  --color-warning: ${resolvePaletteColor(Warning, config)};
  --color-error: ${resolvePaletteColor(Error, config)};
  --color-info: ${resolvePaletteColor(Info, config)};
  
  --bg-primary: ${resolvePaletteBackgroundColor(Primary, config)};
  --bg-secondary: ${resolvePaletteBackgroundColor(Secondary, config)};
  --bg-tertiary: ${resolvePaletteBackgroundColor(Tertiary, config)};
  --bg-muted: ${resolvePaletteBackgroundColor(Muted, config)};
  --bg-inverse: ${resolvePaletteBackgroundColor(Inverse, config)};
  
  --border-primary: ${resolvePaletteBorderColor(Primary, config)};
}
`
    
    paletteExport ++ semanticMappings
  }
}