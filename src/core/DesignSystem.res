// Type-Safe Design System for Tailwind CSS
// High-level semantic design system built on TailwindTypes
// Ensures design system compliance at compile time

open TailwindTypes
open ColorPalette

// Color Scale - Semantic color tokens (regular variants for strictness)
type color = 
  | Primary     // Main brand color
  | Secondary   // Secondary text
  | Tertiary    // Subtle text
  | Muted       // Background text
  | Inverse     // White text on dark backgrounds
  | Success     // Success states
  | Warning     // Warning states
  | Error       // Error states
  | Info        // Info states


// Text color classes - for text elements
let colorToClass = (color: color): string => {
  let palette = defaultPalette
  switch color {
  | Primary => `text-[${getColorFromScale(palette.primary, C900)}]`
  | Secondary => `text-[${getColorFromScale(palette.neutral, C600)}]`  
  | Tertiary => `text-[${getColorFromScale(palette.neutral, C400)}]`
  | Muted => `text-[${getColorFromScale(palette.neutral, C300)}]`
  | Inverse => "text-white"
  | Success => `text-[${getColorFromScale(palette.success, C600)}]`
  | Warning => `text-[${getColorFromScale(palette.warning, C600)}]`
  | Error => `text-[${getColorFromScale(palette.error, C600)}]`
  | Info => `text-[${getColorFromScale(palette.info, C500)}]`
  }
}

// Background color classes - for button backgrounds, etc.
let backgroundColorToClass = (color: color): string => {
  let palette = defaultPalette
  switch color {
  | Primary => `bg-[${getColorFromScale(palette.primary, C900)}]`
  | Secondary => "bg-transparent"
  | Tertiary => `bg-[${getColorFromScale(palette.neutral, C100)}]`
  | Muted => `bg-[${getColorFromScale(palette.neutral, C50)}]`
  | Inverse => `bg-[${getColorFromScale(palette.neutral, C900)}]`
  | Success => `bg-[${getColorFromScale(palette.success, C600)}]`
  | Warning => `bg-[${getColorFromScale(palette.warning, C500)}]`
  | Error => `bg-[${getColorFromScale(palette.error, C600)}]`
  | Info => `bg-[${getColorFromScale(palette.info, C500)}]`
  }
}

// Border color classes - for outlined buttons, etc.
let borderColorToClass = (color: color): string => {
  let palette = defaultPalette
  switch color {
  | Primary => `border-[${getColorFromScale(palette.primary, C900)}]`
  | Secondary => `border-[${getColorFromScale(palette.neutral, C300)}]`
  | Tertiary => `border-[${getColorFromScale(palette.neutral, C200)}]`
  | Muted => `border-[${getColorFromScale(palette.neutral, C100)}]`
  | Inverse => `border-[${getColorFromScale(palette.neutral, C700)}]`
  | Success => `border-[${getColorFromScale(palette.success, C600)}]`
  | Warning => `border-[${getColorFromScale(palette.warning, C500)}]`
  | Error => `border-[${getColorFromScale(palette.error, C600)}]`
  | Info => `border-[${getColorFromScale(palette.info, C500)}]`
  }
}

// Utility function for combining classes
let cx = (classes: array<string>): string => {
  classes
  ->Array.filter(cls => cls !== "")
  ->Array.join(" ")
}

// Typography Combinations - Pre-defined semantic text styles
module Typography = {
  type textStyle = 
    | Display     // Hero headlines
    | Title       // Page titles
    | Heading     // Section headings
    | Subheading  // Subsection headings
    | Body        // Standard body text
    | Caption     // Small supporting text
    | Label       // Form labels

  let textStyleToClasses = (style: textStyle): array<string> => {
    switch style {
    | Display => [
        fontSizeToClass(#XL6),
        fontWeightToClass(#ExtraLight),
        lineHeightToClass(#Tight),
        colorToClass(Primary)
      ]
    | Title => [
        fontSizeToClass(#XL4),
        fontWeightToClass(#Light),
        lineHeightToClass(#Tight),
        colorToClass(Primary)
      ]
    | Heading => [
        fontSizeToClass(#XL2),
        fontWeightToClass(#SemiBold),
        lineHeightToClass(#Normal),
        colorToClass(Primary)
      ]
    | Subheading => [
        fontSizeToClass(#LG),
        fontWeightToClass(#Medium),
        lineHeightToClass(#Normal),
        colorToClass(Secondary)
      ]
    | Body => [
        fontSizeToClass(#Base),
        fontWeightToClass(#Normal),
        lineHeightToClass(#Relaxed),
        colorToClass(Secondary)
      ]
    | Caption => [
        fontSizeToClass(#SM),
        fontWeightToClass(#Medium),
        lineHeightToClass(#Normal),
        colorToClass(Tertiary)
      ]
    | Label => [
        fontSizeToClass(#SM),
        fontWeightToClass(#Medium),
        lineHeightToClass(#Normal),
        colorToClass(Primary)
      ]
    }
  }
}