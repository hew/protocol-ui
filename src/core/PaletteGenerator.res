// Palette Generator - Intelligent Color Palette Creation
// Generates complete, accessible color systems from a single brand color

module CT = ColorTheory

// Helper for float modulo
let mod_float = (x: float, y: float): float => {
  x -. Math.floor(x /. y) *. y
}

// Palette configuration options
type paletteConfig = {
  baseColor: CT.color,
  mode: [#monochromatic | #analogous | #complementary | #triadic | #custom],
  steps: int, // Number of shades to generate (usually 10 for 50-950)
  preserveAccessibility: bool, // Ensure WCAG compliance
  generateSemanticColors: bool, // Auto-generate success/warning/error
}

// Semantic color configuration
type semanticColors = {
  success: CT.color,
  warning: CT.color,
  error: CT.color,
  info: CT.color,
}

// Color scale entry
type colorScaleEntry = {
  weight: int, // 50, 100, 200... 950
  color: CT.color,
  hex: string,
  contrastWithWhite: float,
  contrastWithBlack: float,
  meetsAA_onWhite: bool,
  meetsAA_onBlack: bool,
}

// Complete palette
type palette = {
  name: string,
  baseColor: CT.color,
  scale: array<colorScaleEntry>,
  semanticColors: option<semanticColors>,
  complementary: option<CT.color>,
  analogous: option<(CT.color, CT.color)>,
}

// Generate a color scale with proper distribution
module Scale = {
  // Generate scale weights (50, 100, 200...950)
  let generateWeights = (steps: int): array<int> => {
    if steps <= 0 {
      []
    } else if steps == 10 {
      // Standard scale
      [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]
    } else {
      // Custom scale
      Array.make(~length=steps, 0)
      ->Array.mapWithIndex((_, i) => {
        let progress = Int.toFloat(i) /. Int.toFloat(steps - 1)
        if i == 0 {
          50
        } else if i == steps - 1 {
          950
        } else {
          Int.fromFloat(50. +. progress *. 900.)
        }
      })
    }
  }

  // Generate lightness curve for natural-looking scales
  let generateLightnessCurve = (baseLightness: float, steps: int): array<float> => {
    Array.make(~length=steps, 0.)
    ->Array.mapWithIndex((_, i) => {
      let t = Int.toFloat(i) /. Int.toFloat(steps - 1)
      
      // Use an easing curve for more natural distribution
      // Lighter shades need more spacing, darker shades can be closer
      if t < 0.5 {
        // Lighter half - quadratic easing
        let adjustedT = t *. 2.
        95. -. (95. -. baseLightness) *. adjustedT *. adjustedT
      } else {
        // Darker half - exponential easing
        let adjustedT = (t -. 0.5) *. 2.
        baseLightness -. baseLightness *. Math.pow(adjustedT, ~exp=1.5)
      }
    })
  }

  // Generate a monochromatic scale
  let generateMonochromatic = (baseColor: CT.color, steps: int): array<CT.color> => {
    let hsl = CT.Convert.toHsl(baseColor)
    let lightnessCurve = generateLightnessCurve(hsl.l, steps)
    
    lightnessCurve->Array.map(lightness => {
      CT.HSL({...hsl, l: lightness})
    })
  }

  // Generate scale with slight hue variations for richness
  let generateRichMonochromatic = (baseColor: CT.color, steps: int): array<CT.color> => {
    let hsl = CT.Convert.toHsl(baseColor)
    let lightnessCurve = generateLightnessCurve(hsl.l, steps)
    
    lightnessCurve->Array.mapWithIndex((lightness, i) => {
      let t = Int.toFloat(i) /. Int.toFloat(steps - 1)
      
      // Slight hue shift for warmer lights and cooler darks
      let hueShift = if t < 0.5 {
        // Lighter colors - shift slightly warm
        -5. *. (0.5 -. t)
      } else {
        // Darker colors - shift slightly cool
        5. *. (t -. 0.5)
      }
      
      // Slight saturation adjustment
      let saturationMultiplier = if t < 0.2 {
        // Very light colors need less saturation
        0.3 +. t *. 3.5
      } else if t > 0.8 {
        // Very dark colors need less saturation
        1. -. (t -. 0.8) *. 2.5
      } else {
        1.
      }
      
      CT.HSL({
        h: mod_float(hsl.h +. hueShift, 360.),
        s: Math.min(100., hsl.s *. saturationMultiplier),
        l: lightness,
      })
    })
  }

  // Create a color scale entry with accessibility data
  let createScaleEntry = (color: CT.color, weight: int): colorScaleEntry => {
    let white = CT.RGB({r: 255., g: 255., b: 255.})
    let black = CT.RGB({r: 0., g: 0., b: 0.})
    
    let contrastWithWhite = CT.Analyze.contrastRatio(color, white)
    let contrastWithBlack = CT.Analyze.contrastRatio(color, black)
    
    {
      weight,
      color,
      hex: CT.Convert.toHex(color),
      contrastWithWhite,
      contrastWithBlack,
      meetsAA_onWhite: contrastWithWhite >= 4.5,
      meetsAA_onBlack: contrastWithBlack >= 4.5,
    }
  }
}

// Semantic color generation
module Semantic = {
  // Generate a success color (green-ish) based on brand color
  let generateSuccess = (baseColor: CT.color): CT.color => {
    let hsl = CT.Convert.toHsl(baseColor)
    
    // Target hue for success (green area: 100-140)
    let targetHue = 120.
    let currentHue = hsl.h
    
    // Calculate shortest rotation to green
    let hueDiff = targetHue -. currentHue
    let rotation = if Math.abs(hueDiff) > 180. {
      if hueDiff > 0. {
        hueDiff -. 360.
      } else {
        hueDiff +. 360.
      }
    } else {
      hueDiff
    }
    
    // Blend with green, keeping some brand color influence
    let blendRatio = 0.8 // 80% green, 20% brand
    let newHue = mod_float(currentHue +. rotation *. blendRatio, 360.)
    
    CT.HSL({
      h: newHue,
      s: Math.max(40., Math.min(70., hsl.s)), // Moderate saturation
      l: Math.max(35., Math.min(45., hsl.l)), // Medium lightness
    })
  }

  // Generate a warning color (amber/orange) based on brand color
  let generateWarning = (baseColor: CT.color): CT.color => {
    let hsl = CT.Convert.toHsl(baseColor)
    
    // Target hue for warning (amber area: 30-50)
    let targetHue = 40.
    let currentHue = hsl.h
    
    let hueDiff = targetHue -. currentHue
    let rotation = if Math.abs(hueDiff) > 180. {
      if hueDiff > 0. {
        hueDiff -. 360.
      } else {
        hueDiff +. 360.
      }
    } else {
      hueDiff
    }
    
    let blendRatio = 0.8
    let newHue = mod_float(currentHue +. rotation *. blendRatio, 360.)
    
    CT.HSL({
      h: newHue,
      s: Math.max(60., Math.min(80., hsl.s)), // High saturation for visibility
      l: Math.max(45., Math.min(55., hsl.l)), // Bright enough to stand out
    })
  }

  // Generate an error color (red-ish) based on brand color
  let generateError = (baseColor: CT.color): CT.color => {
    let hsl = CT.Convert.toHsl(baseColor)
    
    // Target hue for error (red area: 0-20 or 340-360)
    let targetHue = 0.
    let currentHue = hsl.h
    
    let hueDiff = targetHue -. currentHue
    let rotation = if Math.abs(hueDiff) > 180. {
      if hueDiff > 0. {
        hueDiff -. 360.
      } else {
        hueDiff +. 360.
      }
    } else {
      hueDiff
    }
    
    let blendRatio = 0.85 // More red influence for errors
    let newHue = mod_float(currentHue +. rotation *. blendRatio, 360.)
    
    CT.HSL({
      h: newHue,
      s: Math.max(55., Math.min(75., hsl.s)), // Good saturation
      l: Math.max(40., Math.min(50., hsl.l)), // Not too dark, not too bright
    })
  }

  // Generate an info color (blue-ish) based on brand color
  let generateInfo = (baseColor: CT.color): CT.color => {
    let hsl = CT.Convert.toHsl(baseColor)
    
    // Target hue for info (blue area: 200-240)
    let targetHue = 220.
    let currentHue = hsl.h
    
    let hueDiff = targetHue -. currentHue
    let rotation = if Math.abs(hueDiff) > 180. {
      if hueDiff > 0. {
        hueDiff -. 360.
      } else {
        hueDiff +. 360.
      }
    } else {
      hueDiff
    }
    
    let blendRatio = 0.75
    let newHue = mod_float(currentHue +. rotation *. blendRatio, 360.)
    
    CT.HSL({
      h: newHue,
      s: Math.max(50., Math.min(70., hsl.s)), // Moderate saturation
      l: Math.max(40., Math.min(50., hsl.l)), // Medium lightness
    })
  }

  // Generate all semantic colors
  let generateSemanticColors = (baseColor: CT.color): semanticColors => {
    {
      success: generateSuccess(baseColor),
      warning: generateWarning(baseColor),
      error: generateError(baseColor),
      info: generateInfo(baseColor),
    }
  }
}

// Main palette generation
let generatePalette = (config: paletteConfig): palette => {
  let weights = Scale.generateWeights(config.steps)
  
  // Generate the main color scale based on mode
  let colorScale = switch config.mode {
  | #monochromatic => Scale.generateRichMonochromatic(config.baseColor, Array.length(weights))
  | #analogous => {
      // Use analogous colors for variety in the scale
      let _analogousColors = CT.Harmony.analogous(config.baseColor)
      Scale.generateRichMonochromatic(config.baseColor, Array.length(weights))
    }
  | #complementary => {
      // Mix with complement for richer scale
      let complement = CT.Manipulate.complement(config.baseColor)
      Array.make(~length=Array.length(weights), 0)
      ->Array.mapWithIndex((_, i) => {
        let t = Int.toFloat(i) /. Int.toFloat(Array.length(weights) - 1)
        let mixRatio = t *. 0.1 // Subtle complement mixing
        CT.Manipulate.mix(config.baseColor, complement, mixRatio)
        ->CT.Manipulate.lighten((1. -. t) *. 45.)
        ->CT.Manipulate.darken(t *. 45.)
      })
    }
  | #triadic => Scale.generateRichMonochromatic(config.baseColor, Array.length(weights))
  | #custom => Scale.generateMonochromatic(config.baseColor, Array.length(weights))
  }
  
  // Create scale entries with accessibility data
  let scale = weights->Array.mapWithIndex((weight, i) => {
    switch colorScale[i] {
    | Some(color) => Scale.createScaleEntry(color, weight)
    | None => Scale.createScaleEntry(config.baseColor, weight) // Fallback
    }
  })
  
  // Ensure accessibility if requested
  let accessibleScale = if config.preserveAccessibility {
    scale->Array.map(entry => {
      // Adjust colors that don't meet minimum contrast
      if entry.weight <= 400 && !entry.meetsAA_onWhite {
        // Light colors should work on white
        let adjusted = CT.Manipulate.darken(entry.color, 5.)
        Scale.createScaleEntry(adjusted, entry.weight)
      } else if entry.weight >= 600 && !entry.meetsAA_onBlack {
        // Dark colors should work on black
        let adjusted = CT.Manipulate.lighten(entry.color, 5.)
        Scale.createScaleEntry(adjusted, entry.weight)
      } else {
        entry
      }
    })
  } else {
    scale
  }
  
  // Generate semantic colors if requested
  let semanticColors = if config.generateSemanticColors {
    Some(Semantic.generateSemanticColors(config.baseColor))
  } else {
    None
  }
  
  // Generate harmony colors
  let complement = switch config.mode {
  | #complementary => Some(CT.Manipulate.complement(config.baseColor))
  | _ => None
  }
  
  let analogous = switch config.mode {
  | #analogous => {
      let colors = CT.Harmony.analogous(config.baseColor)
      switch (colors[0], colors[2]) {
      | (Some(c1), Some(c2)) => Some((c1, c2))
      | _ => None
      }
    }
  | _ => None
  }
  
  {
    name: "Generated Palette",
    baseColor: config.baseColor,
    scale: accessibleScale,
    semanticColors,
    complementary: complement,
    analogous,
  }
}

// Preset palette configurations
module Presets = {
  let corporate = (brandColor: CT.color): palette => {
    generatePalette({
      baseColor: brandColor,
      mode: #monochromatic,
      steps: 11, // Standard 50-950 scale
      preserveAccessibility: true,
      generateSemanticColors: true,
    })
  }
  
  let vibrant = (brandColor: CT.color): palette => {
    generatePalette({
      baseColor: brandColor,
      mode: #analogous,
      steps: 11,
      preserveAccessibility: true,
      generateSemanticColors: true,
    })
  }
  
  let balanced = (brandColor: CT.color): palette => {
    generatePalette({
      baseColor: brandColor,
      mode: #complementary,
      steps: 11,
      preserveAccessibility: true,
      generateSemanticColors: true,
    })
  }
  
  let minimal = (brandColor: CT.color): palette => {
    generatePalette({
      baseColor: brandColor,
      mode: #monochromatic,
      steps: 5, // Just 5 key shades
      preserveAccessibility: true,
      generateSemanticColors: false,
    })
  }
}

// Utility functions
module Utils = {
  // Export palette as Tailwind config object
  let toTailwindConfig = (palette: palette, colorName: string): string => {
    let scaleObject = palette.scale
    ->Array.map(entry => {
      `'${Int.toString(entry.weight)}': '${entry.hex}'`
    })
    ->Array.join(",\n        ")
    
    let semanticObject = switch palette.semanticColors {
    | Some(semantic) => `,
      success: '${CT.Convert.toHex(semantic.success)}',
      warning: '${CT.Convert.toHex(semantic.warning)}',
      error: '${CT.Convert.toHex(semantic.error)}',
      info: '${CT.Convert.toHex(semantic.info)}'`
    | None => ""
    }
    
    `colors: {
      '${colorName}': {
        ${scaleObject}${semanticObject}
      }
    }`
  }
  
  // Export palette as CSS custom properties
  let toCssVariables = (palette: palette, prefix: string): string => {
    let scaleVars = palette.scale
    ->Array.map(entry => {
      `  --${prefix}-${Int.toString(entry.weight)}: ${entry.hex};`
    })
    ->Array.join("\n")
    
    let semanticVars = switch palette.semanticColors {
    | Some(semantic) => `
  --${prefix}-success: ${CT.Convert.toHex(semantic.success)};
  --${prefix}-warning: ${CT.Convert.toHex(semantic.warning)};
  --${prefix}-error: ${CT.Convert.toHex(semantic.error)};
  --${prefix}-info: ${CT.Convert.toHex(semantic.info)};`
    | None => ""
    }
    
    `:root {
${scaleVars}${semanticVars}
}`
  }
  
  // Find the best text color for a background
  let getBestTextColor = (backgroundColor: CT.color, palette: palette): CT.color => {
    // Try palette extremes first
    let lightOption = switch palette.scale[0] {
    | Some(entry) => entry.color
    | None => CT.RGB({r: 255., g: 255., b: 255.}) // Default to white
    }
    let darkOption = switch palette.scale[Array.length(palette.scale) - 1] {
    | Some(entry) => entry.color
    | None => CT.RGB({r: 0., g: 0., b: 0.}) // Default to black
    }
    
    let lightContrast = CT.Analyze.contrastRatio(backgroundColor, lightOption)
    let darkContrast = CT.Analyze.contrastRatio(backgroundColor, darkOption)
    
    if darkContrast >= lightContrast && darkContrast >= 4.5 {
      darkOption
    } else if lightContrast >= 4.5 {
      lightOption
    } else {
      // Fallback to pure black or white
      let blackContrast = CT.Analyze.contrastRatio(backgroundColor, CT.RGB({r: 0., g: 0., b: 0.}))
      let whiteContrast = CT.Analyze.contrastRatio(backgroundColor, CT.RGB({r: 255., g: 255., b: 255.}))
      
      if whiteContrast >= blackContrast {
        CT.RGB({r: 255., g: 255., b: 255.})
      } else {
        CT.RGB({r: 0., g: 0., b: 0.})
      }
    }
  }
}