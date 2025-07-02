// Theme System - Contextual application of design tokens
// Handles dark mode, accessibility variants, and environmental contexts

module DS = DesignSystem

// Core theme variants
type theme = 
  | Light 
  | Dark 
  | HighContrast
  | ReducedMotion
  | Sepia

// Theme-aware color resolution
let resolveColor = (color: DS.color, theme: theme): string => {
  switch (color, theme) {
  // Light theme (default)
  | (Primary, Light) => "text-neutral-900"
  | (Secondary, Light) => "text-neutral-600" 
  | (Tertiary, Light) => "text-neutral-400"
  | (Muted, Light) => "text-neutral-300"
  | (Inverse, Light) => "text-white"
  | (Success, Light) => "text-green-700"
  | (Warning, Light) => "text-amber-600"
  | (Error, Light) => "text-red-600"
  | (Info, Light) => "text-blue-600"
  
  // Dark theme
  | (Primary, Dark) => "text-white"
  | (Secondary, Dark) => "text-gray-200"
  | (Tertiary, Dark) => "text-gray-400"
  | (Muted, Dark) => "text-gray-500"
  | (Inverse, Dark) => "text-gray-900"
  | (Success, Dark) => "text-green-400"
  | (Warning, Dark) => "text-amber-400"
  | (Error, Dark) => "text-red-400"
  | (Info, Dark) => "text-blue-400"
  
  // High contrast theme (accessibility)
  | (Primary, HighContrast) => "text-black"
  | (Secondary, HighContrast) => "text-gray-800"
  | (Tertiary, HighContrast) => "text-gray-700"
  | (Muted, HighContrast) => "text-gray-600"
  | (Inverse, HighContrast) => "text-white"
  | (Success, HighContrast) => "text-green-800"
  | (Warning, HighContrast) => "text-yellow-800"
  | (Error, HighContrast) => "text-red-800"
  | (Info, HighContrast) => "text-blue-800"
  
  // Reduced motion theme (keeps light colors, affects animations elsewhere)
  | (Primary, ReducedMotion) => "text-gray-900"
  | (Secondary, ReducedMotion) => "text-gray-700"
  | (Tertiary, ReducedMotion) => "text-gray-500"
  | (Muted, ReducedMotion) => "text-gray-400"
  | (Inverse, ReducedMotion) => "text-white"
  | (Success, ReducedMotion) => "text-green-700"
  | (Warning, ReducedMotion) => "text-amber-600"
  | (Error, ReducedMotion) => "text-red-600"
  | (Info, ReducedMotion) => "text-blue-600"
  
  // Sepia theme (reading comfort)
  | (Primary, Sepia) => "text-amber-900"
  | (Secondary, Sepia) => "text-amber-800"
  | (Tertiary, Sepia) => "text-amber-600"
  | (Muted, Sepia) => "text-amber-500"
  | (Inverse, Sepia) => "text-amber-50"
  | (Success, Sepia) => "text-green-700"
  | (Warning, Sepia) => "text-orange-700"
  | (Error, Sepia) => "text-red-700"
  | (Info, Sepia) => "text-indigo-700"
  }
}

// Background color resolution for theme contexts
let resolveBackgroundColor = (color: DS.color, theme: theme): string => {
  switch (color, theme) {
  // Light backgrounds
  | (Primary, Light) => "bg-neutral-900"
  | (Secondary, Light) => "bg-transparent"
  | (Tertiary, Light) => "bg-neutral-100"
  | (Muted, Light) => "bg-neutral-50"
  | (Inverse, Light) => "bg-gray-900"
  
  // Dark backgrounds
  | (Primary, Dark) => "bg-gray-900"
  | (Secondary, Dark) => "bg-gray-800"
  | (Tertiary, Dark) => "bg-gray-700"
  | (Muted, Dark) => "bg-gray-600"
  | (Inverse, Dark) => "bg-white"
  
  // High contrast backgrounds
  | (Primary, HighContrast) => "bg-white"
  | (Secondary, HighContrast) => "bg-gray-100"
  | (Tertiary, HighContrast) => "bg-gray-200"
  | (Muted, HighContrast) => "bg-gray-300"
  | (Inverse, HighContrast) => "bg-black"
  
  // Reduced motion (same as light)
  | (Primary, ReducedMotion) => "bg-white"
  | (Secondary, ReducedMotion) => "bg-gray-50"
  | (Tertiary, ReducedMotion) => "bg-gray-100"
  | (Muted, ReducedMotion) => "bg-gray-200"
  | (Inverse, ReducedMotion) => "bg-gray-900"
  
  // Sepia backgrounds
  | (Primary, Sepia) => "bg-amber-50"
  | (Secondary, Sepia) => "bg-amber-100"
  | (Tertiary, Sepia) => "bg-amber-200"
  | (Muted, Sepia) => "bg-amber-300"
  | (Inverse, Sepia) => "bg-amber-900"
  
  | _ => "bg-transparent" // fallback for status colors
  }
}

// Border color resolution
let resolveBorderColor = (color: DS.color, theme: theme): string => {
  switch (color, theme) {
  | (Primary, Light) => "border-neutral-900"
  | (Primary, Dark) => "border-gray-600"
  | (Primary, HighContrast) => "border-black"
  | (Primary, ReducedMotion) => "border-gray-300"
  | (Primary, Sepia) => "border-amber-300"
  | _ => "border-transparent"
  }
}

// Theme detection utilities
module Detection = {
  // Detect user's preferred theme from system/browser
  let getSystemTheme = (): theme => {
    // In a real implementation, this would check:
    // - window.matchMedia("(prefers-color-scheme: dark)")
    // - window.matchMedia("(prefers-contrast: high)")  
    // - window.matchMedia("(prefers-reduced-motion: reduce)")
    Light // Default fallback
  }
  
  // Get theme with fallback chain
  let resolveTheme = (~userPreference: option<theme>=?, ~systemPreference: option<theme>=?, ()): theme => {
    switch userPreference {
    | Some(theme) => theme
    | None => switch systemPreference {
      | Some(theme) => theme
      | None => getSystemTheme()
      }
    }
  }
}

// Theme CSS class generation
module Classes = {
  // Generate CSS classes for theme application
  let themeClasses = (theme: theme): string => {
    switch theme {
    | Light => "theme-light"
    | Dark => "theme-dark dark"
    | HighContrast => "theme-high-contrast contrast-more"
    | ReducedMotion => "theme-reduced-motion motion-reduce"
    | Sepia => "theme-sepia"
    }
  }
  
  // Generate data attributes for theme targeting
  let themeDataAttribute = (theme: theme): string => {
    switch theme {
    | Light => "data-theme=\"light\""
    | Dark => "data-theme=\"dark\""
    | HighContrast => "data-theme=\"high-contrast\""
    | ReducedMotion => "data-theme=\"reduced-motion\""
    | Sepia => "data-theme=\"sepia\""
    }
  }
}

// Theme-aware typography
module Typography = {
  open DS.Typography
  
  // Resolve typography styles with theme context
  let resolveTextStyle = (style: textStyle, theme: theme): array<string> => {
    let baseClasses = textStyleToClasses(style)
    let themeAwareClasses = baseClasses->Array.map(cls => {
      // Replace color classes with theme-aware versions
      if String.includes(cls, "text-") {
        // Extract the color intent and re-resolve with theme
        // This is a simplified version - in practice you'd parse the semantic color
        switch style {
        | Display | Title | Heading | Label => resolveColor(Primary, theme)
        | Body | Subheading => resolveColor(Secondary, theme) 
        | Caption => resolveColor(Tertiary, theme)
        }
      } else {
        cls
      }
    })
    themeAwareClasses
  }
}

// Animation and motion preferences
module Motion = {
  type motionPreference = 
    | NoPreference
    | Reduce
    | Remove
  
  let getMotionClasses = (theme: theme): array<string> => {
    switch theme {
    | ReducedMotion => ["motion-reduce", "transition-none"]
    | _ => ["transition-all", "duration-200", "ease-in-out"]
    }
  }
  
  let shouldAnimate = (theme: theme): bool => {
    switch theme {
    | ReducedMotion => false
    | _ => true
    }
  }
}

// Default theme instance
let defaultTheme = Light