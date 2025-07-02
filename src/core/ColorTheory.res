// Color Theory Module - Scientific Color Manipulation
// Foundation for intelligent palette generation based on color science

// Color representation types
type rgb = {
  r: float, // 0-255
  g: float, // 0-255
  b: float, // 0-255
}

type hsl = {
  h: float, // 0-360 degrees
  s: float, // 0-100 percentage
  l: float, // 0-100 percentage
}

type hsv = {
  h: float, // 0-360 degrees
  s: float, // 0-100 percentage
  v: float, // 0-100 percentage
}

type lab = {
  l: float, // 0-100 lightness
  a: float, // -128 to 127 green-red
  b: float, // -128 to 127 blue-yellow
}

// Core color type that can represent any format
type color = 
  | RGB(rgb)
  | HSL(hsl)
  | HSV(hsv)
  | LAB(lab)
  | Hex(string)

// Conversion utilities
module Convert = {
  // Modulo for floats
  let mod_float = (x: float, y: float): float => {
    x -. Math.floor(x /. y) *. y
  }
  
  // Clamp value between min and max
  let clamp = (value: float, min: float, max: float): float => {
    Math.max(min, Math.min(max, value))
  }

  // Hex to RGB conversion
  let hexToRgb = (hex: string): result<rgb, string> => {
    let cleanHex = hex->String.startsWith("#") 
      ? hex->String.sliceToEnd(~start=1) 
      : hex
    
    if cleanHex->String.length != 6 {
      Error("Invalid hex color length")
    } else {
      let parseInt16 = %raw(`function(str) { 
        const result = parseInt(str, 16);
        return isNaN(result) ? undefined : result;
      }`)
      
      switch (
        cleanHex->String.slice(~start=0, ~end=2)->parseInt16,
        cleanHex->String.slice(~start=2, ~end=4)->parseInt16,
        cleanHex->String.slice(~start=4, ~end=6)->parseInt16
      ) {
      | (Some(r), Some(g), Some(b)) => 
        Ok({r: Int.toFloat(r), g: Int.toFloat(g), b: Int.toFloat(b)})
      | _ => Error("Invalid hex color format")
      }
    }
  }

  // RGB to Hex conversion
  let rgbToHex = (rgb: rgb): string => {
    let toHexComponent = (value: float): string => {
      let intValue = clamp(value, 0., 255.)->Int.fromFloat
      let toHex = (n: int): string => {
        Int.toString(n, ~radix=16)
      }
      let hex = toHex(intValue)
      hex->String.length == 1 ? "0" ++ hex : hex
    }
    
    "#" ++ toHexComponent(rgb.r) ++ toHexComponent(rgb.g) ++ toHexComponent(rgb.b)
  }

  // RGB to HSL conversion
  let rgbToHsl = (rgb: rgb): hsl => {
    let r = rgb.r /. 255.
    let g = rgb.g /. 255.
    let b = rgb.b /. 255.
    
    let max = Math.max(r, Math.max(g, b))
    let min = Math.min(r, Math.min(g, b))
    let delta = max -. min
    
    let l = (max +. min) /. 2.
    
    if delta == 0. {
      {h: 0., s: 0., l: l *. 100.}
    } else {
      let s = delta /. (1. -. Math.abs(2. *. l -. 1.))
      
      let h = if max == r {
        mod_float((g -. b) /. delta +. (g < b ? 6. : 0.), 6.)
      } else if max == g {
        (b -. r) /. delta +. 2.
      } else {
        (r -. g) /. delta +. 4.
      }
      
      {h: h *. 60., s: s *. 100., l: l *. 100.}
    }
  }

  // HSL to RGB conversion
  let hslToRgb = (hsl: hsl): rgb => {
    let h = hsl.h /. 360.
    let s = hsl.s /. 100.
    let l = hsl.l /. 100.
    
    if s == 0. {
      let gray = l *. 255.
      {r: gray, g: gray, b: gray}
    } else {
      let hue2rgb = (p: float, q: float, t: float): float => {
        let t = mod_float(t, 1.)
        if t < 1. /. 6. {
          p +. (q -. p) *. 6. *. t
        } else if t < 1. /. 2. {
          q
        } else if t < 2. /. 3. {
          p +. (q -. p) *. (2. /. 3. -. t) *. 6.
        } else {
          p
        }
      }
      
      let q = if l < 0.5 {
        l *. (1. +. s)
      } else {
        l +. s -. l *. s
      }
      
      let p = 2. *. l -. q
      
      {
        r: hue2rgb(p, q, h +. 1. /. 3.) *. 255.,
        g: hue2rgb(p, q, h) *. 255.,
        b: hue2rgb(p, q, h -. 1. /. 3.) *. 255.,
      }
    }
  }

  // RGB to HSV conversion
  let rgbToHsv = (rgb: rgb): hsv => {
    let r = rgb.r /. 255.
    let g = rgb.g /. 255.
    let b = rgb.b /. 255.
    
    let max = Math.max(r, Math.max(g, b))
    let min = Math.min(r, Math.min(g, b))
    let delta = max -. min
    
    let v = max
    let s = max == 0. ? 0. : delta /. max
    
    let h = if delta == 0. {
      0.
    } else if max == r {
      mod_float((g -. b) /. delta +. (g < b ? 6. : 0.), 6.)
    } else if max == g {
      (b -. r) /. delta +. 2.
    } else {
      (r -. g) /. delta +. 4.
    }
    
    {h: h *. 60., s: s *. 100., v: v *. 100.}
  }

  // HSV to RGB conversion
  let hsvToRgb = (hsv: hsv): rgb => {
    let h = hsv.h /. 60.
    let s = hsv.s /. 100.
    let v = hsv.v /. 100.
    
    let c = v *. s
    let x = c *. (1. -. Math.abs(mod_float(h, 2.) -. 1.))
    let m = v -. c
    
    let (r', g', b') = if h < 1. {
      (c, x, 0.)
    } else if h < 2. {
      (x, c, 0.)
    } else if h < 3. {
      (0., c, x)
    } else if h < 4. {
      (0., x, c)
    } else if h < 5. {
      (x, 0., c)
    } else {
      (c, 0., x)
    }
    
    {
      r: (r' +. m) *. 255.,
      g: (g' +. m) *. 255.,
      b: (b' +. m) *. 255.,
    }
  }

  // Convert any color type to RGB
  let toRgb = (color: color): rgb => {
    switch color {
    | RGB(rgb) => rgb
    | HSL(hsl) => hslToRgb(hsl)
    | HSV(hsv) => hsvToRgb(hsv)
    | Hex(hex) => switch hexToRgb(hex) {
      | Ok(rgb) => rgb
      | Error(_) => {r: 0., g: 0., b: 0.} // Default to black on error
      }
    | LAB(_) => {r: 0., g: 0., b: 0.} // LAB conversion is complex, placeholder
    }
  }

  // Convert any color type to HSL
  let toHsl = (color: color): hsl => {
    switch color {
    | HSL(hsl) => hsl
    | RGB(rgb) => rgbToHsl(rgb)
    | HSV(hsv) => rgbToHsl(hsvToRgb(hsv))
    | Hex(hex) => switch hexToRgb(hex) {
      | Ok(rgb) => rgbToHsl(rgb)
      | Error(_) => {h: 0., s: 0., l: 0.}
      }
    | LAB(_) => {h: 0., s: 0., l: 0.} // Placeholder
    }
  }

  // Convert any color type to hex string
  let toHex = (color: color): string => {
    switch color {
    | Hex(hex) => hex->String.startsWith("#") ? hex : "#" ++ hex
    | RGB(rgb) => rgbToHex(rgb)
    | HSL(hsl) => rgbToHex(hslToRgb(hsl))
    | HSV(hsv) => rgbToHex(hsvToRgb(hsv))
    | LAB(_) => "#000000" // Placeholder
    }
  }
}

// Color manipulation functions
module Manipulate = {
  // Lighten a color by percentage (0-100)
  let lighten = (color: color, amount: float): color => {
    let hsl = Convert.toHsl(color)
    let newL = Math.min(100., hsl.l +. amount)
    HSL({...hsl, l: newL})
  }

  // Darken a color by percentage (0-100)
  let darken = (color: color, amount: float): color => {
    let hsl = Convert.toHsl(color)
    let newL = Math.max(0., hsl.l -. amount)
    HSL({...hsl, l: newL})
  }

  // Saturate a color by percentage (0-100)
  let saturate = (color: color, amount: float): color => {
    let hsl = Convert.toHsl(color)
    let newS = Math.min(100., hsl.s +. amount)
    HSL({...hsl, s: newS})
  }

  // Desaturate a color by percentage (0-100)
  let desaturate = (color: color, amount: float): color => {
    let hsl = Convert.toHsl(color)
    let newS = Math.max(0., hsl.s -. amount)
    HSL({...hsl, s: newS})
  }

  // Rotate hue by degrees
  let rotate = (color: color, degrees: float): color => {
    let hsl = Convert.toHsl(color)
    let newH = mod_float(hsl.h +. degrees, 360.)
    HSL({...hsl, h: newH})
  }

  // Mix two colors with a ratio (0-1, where 0 is all color1, 1 is all color2)
  let mix = (color1: color, color2: color, ratio: float): color => {
    let rgb1 = Convert.toRgb(color1)
    let rgb2 = Convert.toRgb(color2)
    let ratio = Convert.clamp(ratio, 0., 1.)
    
    RGB({
      r: rgb1.r *. (1. -. ratio) +. rgb2.r *. ratio,
      g: rgb1.g *. (1. -. ratio) +. rgb2.g *. ratio,
      b: rgb1.b *. (1. -. ratio) +. rgb2.b *. ratio,
    })
  }

  // Create a grayscale version of the color
  let grayscale = (color: color): color => {
    let hsl = Convert.toHsl(color)
    HSL({...hsl, s: 0.})
  }

  // Invert a color
  let invert = (color: color): color => {
    let rgb = Convert.toRgb(color)
    RGB({
      r: 255. -. rgb.r,
      g: 255. -. rgb.g,
      b: 255. -. rgb.b,
    })
  }

  // Get the complement of a color (opposite on color wheel)
  let complement = (color: color): color => {
    rotate(color, 180.)
  }
}

// Color analysis functions
module Analyze = {
  // Calculate relative luminance (for WCAG contrast calculations)
  let relativeLuminance = (color: color): float => {
    let rgb = Convert.toRgb(color)
    
    let toLinear = (value: float): float => {
      let v = value /. 255.
      if v <= 0.03928 {
        v /. 12.92
      } else {
        Math.pow((v +. 0.055) /. 1.055, ~exp=2.4)
      }
    }
    
    let r = toLinear(rgb.r)
    let g = toLinear(rgb.g)
    let b = toLinear(rgb.b)
    
    0.2126 *. r +. 0.7152 *. g +. 0.0722 *. b
  }

  // Calculate contrast ratio between two colors (WCAG)
  let contrastRatio = (color1: color, color2: color): float => {
    let lum1 = relativeLuminance(color1)
    let lum2 = relativeLuminance(color2)
    
    let lighter = Math.max(lum1, lum2)
    let darker = Math.min(lum1, lum2)
    
    (lighter +. 0.05) /. (darker +. 0.05)
  }

  // Check if two colors meet WCAG AA standards
  let meetsWCAG_AA = (color1: color, color2: color, ~largeText: bool=false): bool => {
    let ratio = contrastRatio(color1, color2)
    if largeText {
      ratio >= 3.0
    } else {
      ratio >= 4.5
    }
  }

  // Check if two colors meet WCAG AAA standards
  let meetsWCAG_AAA = (color1: color, color2: color, ~largeText: bool=false): bool => {
    let ratio = contrastRatio(color1, color2)
    if largeText {
      ratio >= 4.5
    } else {
      ratio >= 7.0
    }
  }

  // Determine if a color is considered "light" or "dark"
  let isLight = (color: color): bool => {
    relativeLuminance(color) > 0.5
  }

  // Get the perceived brightness (0-255)
  let perceivedBrightness = (color: color): float => {
    let rgb = Convert.toRgb(color)
    // Using the formula from http://alienryderflex.com/hsp.html
    Math.sqrt(
      0.299 *. rgb.r *. rgb.r +.
      0.587 *. rgb.g *. rgb.g +.
      0.114 *. rgb.b *. rgb.b
    )
  }
}

// Color harmony functions
module Harmony = {
  // Generate analogous colors (adjacent on color wheel)
  let analogous = (color: color, ~angle: float=30.): array<color> => {
    [
      Manipulate.rotate(color, -.angle),
      color,
      Manipulate.rotate(color, angle),
    ]
  }

  // Generate triadic colors (120 degrees apart)
  let triadic = (color: color): array<color> => {
    [
      color,
      Manipulate.rotate(color, 120.),
      Manipulate.rotate(color, 240.),
    ]
  }

  // Generate tetradic colors (90 degrees apart)
  let tetradic = (color: color): array<color> => {
    [
      color,
      Manipulate.rotate(color, 90.),
      Manipulate.rotate(color, 180.),
      Manipulate.rotate(color, 270.),
    ]
  }

  // Generate split complementary colors
  let splitComplementary = (color: color, ~angle: float=30.): array<color> => {
    [
      color,
      Manipulate.rotate(color, 180. -. angle),
      Manipulate.rotate(color, 180. +. angle),
    ]
  }

  // Generate monochromatic colors (different shades of same hue)
  let monochromatic = (color: color, ~steps: int=5): array<color> => {
    let hsl = Convert.toHsl(color)
    let stepSize = 100. /. Int.toFloat(steps + 1)
    
    Array.make(~length=steps, 0)
    ->Array.mapWithIndex((_, i) => {
      let lightness = stepSize *. Int.toFloat(i + 1)
      HSL({...hsl, l: lightness})
    })
  }
}

// Utility functions
module Utils = {
  // Parse a color string (hex or named) into a color type
  let parse = (colorString: string): option<color> => {
    let trimmed = colorString->String.trim
    
    if trimmed->String.startsWith("#") || trimmed->String.length == 6 {
      Some(Hex(trimmed))
    } else {
      None // Could be extended to support named colors
    }
  }

  // Format a color for CSS usage
  let toCssString = (color: color): string => {
    switch color {
    | Hex(hex) => hex->String.startsWith("#") ? hex : "#" ++ hex
    | RGB(rgb) => `rgb(${Int.fromFloat(rgb.r)->Int.toString}, ${Int.fromFloat(rgb.g)->Int.toString}, ${Int.fromFloat(rgb.b)->Int.toString})`
    | HSL(hsl) => `hsl(${Int.fromFloat(hsl.h)->Int.toString}, ${Int.fromFloat(hsl.s)->Int.toString}%, ${Int.fromFloat(hsl.l)->Int.toString}%)`
    | HSV(_) => Convert.toHex(color) // Convert to hex for CSS
    | LAB(_) => Convert.toHex(color) // Convert to hex for CSS
    }
  }

  // Create a color from RGB values
  let fromRgb = (r: float, g: float, b: float): color => {
    RGB({
      r: Convert.clamp(r, 0., 255.),
      g: Convert.clamp(g, 0., 255.),
      b: Convert.clamp(b, 0., 255.),
    })
  }

  // Create a color from HSL values
  let fromHsl = (h: float, s: float, l: float): color => {
    HSL({
      h: mod_float(h, 360.),
      s: Convert.clamp(s, 0., 100.),
      l: Convert.clamp(l, 0., 100.),
    })
  }
}