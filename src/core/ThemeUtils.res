// Theme Utilities and Advanced Helpers
// Advanced theming utilities for complex scenarios

open Themes
module DS = DesignSystem

// CSS Custom Properties generation for themes
module CSSVariables = {
  type cssVar = {
    name: string,
    value: string,
  }
  
  // Generate CSS custom properties for a theme
  let generateThemeVariables = (theme: theme): array<cssVar> => {
    let colorVars = [
      {name: "--color-primary", value: resolveColor(Primary, theme)->String.replace("text-", "")},
      {name: "--color-secondary", value: resolveColor(Secondary, theme)->String.replace("text-", "")},
      {name: "--color-tertiary", value: resolveColor(Tertiary, theme)->String.replace("text-", "")},
      {name: "--color-muted", value: resolveColor(Muted, theme)->String.replace("text-", "")},
      {name: "--color-inverse", value: resolveColor(Inverse, theme)->String.replace("text-", "")},
      {name: "--color-success", value: resolveColor(Success, theme)->String.replace("text-", "")},
      {name: "--color-warning", value: resolveColor(Warning, theme)->String.replace("text-", "")},
      {name: "--color-error", value: resolveColor(Error, theme)->String.replace("text-", "")},
      {name: "--color-info", value: resolveColor(Info, theme)->String.replace("text-", "")},
    ]
    
    let backgroundVars = [
      {name: "--bg-primary", value: resolveBackgroundColor(Primary, theme)->String.replace("bg-", "")},
      {name: "--bg-secondary", value: resolveBackgroundColor(Secondary, theme)->String.replace("bg-", "")},
      {name: "--bg-tertiary", value: resolveBackgroundColor(Tertiary, theme)->String.replace("bg-", "")},
    ]
    
    let motionVars = switch theme {
    | ReducedMotion => [
        {name: "--transition-duration", value: "0ms"},
        {name: "--animation-duration", value: "0ms"},
      ]
    | _ => [
        {name: "--transition-duration", value: "200ms"},
        {name: "--animation-duration", value: "300ms"},
      ]
    }
    
    Array.concat(colorVars, Array.concat(backgroundVars, motionVars))
  }
  
  // Convert variables to CSS string
  let variablesToCSS = (vars: array<cssVar>): string => {
    vars
    ->Array.map(var => `${var.name}: ${var.value};`)
    ->Array.join("\n  ")
  }
  
  // Generate complete CSS for theme
  let generateThemeCSS = (theme: theme): string => {
    let vars = generateThemeVariables(theme)
    let selector = switch theme {
    | Light => ":root, [data-theme=\"light\"]"
    | Dark => "[data-theme=\"dark\"]"
    | HighContrast => "[data-theme=\"high-contrast\"]"
    | ReducedMotion => "[data-theme=\"reduced-motion\"]"
    | Sepia => "[data-theme=\"sepia\"]"
    }
    
    `${selector} {
  ${variablesToCSS(vars)}
}`
  }
}

// Theme transition effects
module Transitions = {
  type transitionConfig = {
    duration: int, // milliseconds
    easing: string,
    properties: array<string>,
  }
  
  let defaultConfig = {
    duration: 300,
    easing: "cubic-bezier(0.4, 0, 0.2, 1)",
    properties: ["color", "background-color", "border-color"],
  }
  
  let getTransitionClasses = (theme: theme, ~config: transitionConfig=defaultConfig, ()): array<string> => {
    switch theme {
    | ReducedMotion => ["transition-none"]
    | _ => [
        "transition-all",
        `duration-${Int.toString(config.duration)}`,
        `ease-${config.easing}`,
      ]
    }
  }
  
  // Generate CSS transition string
  let generateTransitionCSS = (theme: theme, ~config: transitionConfig=defaultConfig, ()): string => {
    switch theme {
    | ReducedMotion => "transition: none;"
    | _ => {
        let properties = config.properties->Array.join(", ")
        `transition: ${properties} ${Int.toString(config.duration)}ms ${config.easing};`
      }
    }
  }
}

// Theme-aware component helpers
module ComponentHelpers = {
  // Generate component classes with theme context
  let themedComponent = (
    ~baseClasses: array<string>,
    ~theme: theme,
    ~colorProps: array<(DS.color, [#text | #bg | #border])>=[]
  ): string => {
    let themedClasses = colorProps->Array.map(((color, prop)) => {
      switch prop {
      | #text => resolveColor(color, theme)
      | #bg => resolveBackgroundColor(color, theme)
      | #border => resolveBorderColor(color, theme)
      }
    })
    
    let motionClasses = Motion.getMotionClasses(theme)
    
    DS.cx(Array.concat(baseClasses, Array.concat(themedClasses, motionClasses)))
  }
  
  // Smart contrast calculation
  let getContrastingColor = (backgroundColor: DS.color, theme: theme): DS.color => {
    switch (backgroundColor, theme) {
    | (Primary, Light) => Inverse
    | (Primary, Dark) => Primary
    | (Secondary | Tertiary | Muted, Light) => Primary
    | (Secondary | Tertiary | Muted, Dark) => Inverse
    | (Inverse, _) => Primary
    | _ => Primary
    }
  }
  
  // Interactive state classes
  let interactiveClasses = (
    ~theme: theme,
    ~baseColor: DS.color,
    ~hoverColor: option<DS.color>=?,
    ~focusColor: option<DS.color>=?,
    ()
  ): array<string> => {
    let baseClass = resolveColor(baseColor, theme)
    let hoverClass = switch hoverColor {
    | Some(color) => "hover:" ++ resolveColor(color, theme)
    | None => "hover:" ++ resolveColor(Secondary, theme)
    }
    let focusClass = switch focusColor {
    | Some(color) => "focus:" ++ resolveColor(color, theme)
    | None => "focus:" ++ resolveColor(Primary, theme)
    }
    
    let motionClasses = Motion.getMotionClasses(theme)
    
    [baseClass, hoverClass, focusClass, ...motionClasses]
  }
}

// Theme debugging and development utilities
module Debug = {
  type accessibilityInfo = {
    highContrast: bool,
    reducedMotion: bool,
  }

  type themeInfo = {
    name: string,
    colors: array<(string, string)>,
    accessibility: accessibilityInfo,
  }
  
  let getThemeInfo = (theme: theme): themeInfo => {
    let name = switch theme {
    | Light => "Light"
    | Dark => "Dark" 
    | HighContrast => "High Contrast"
    | ReducedMotion => "Reduced Motion"
    | Sepia => "Sepia"
    }
    
    let colors = [
      ("Primary", resolveColor(Primary, theme)),
      ("Secondary", resolveColor(Secondary, theme)),
      ("Tertiary", resolveColor(Tertiary, theme)),
      ("Success", resolveColor(Success, theme)),
      ("Warning", resolveColor(Warning, theme)),
      ("Error", resolveColor(Error, theme)),
    ]
    
    let accessibility: accessibilityInfo = {
      highContrast: theme === HighContrast,
      reducedMotion: theme === ReducedMotion,
    }
    
    {name, colors, accessibility}
  }
  
  // Generate theme preview component
  let debugThemePreview = (theme: theme): string => {
    let info = getThemeInfo(theme)
    let colorSwatches = info.colors
      ->Array.map(((name, className)) => 
        `<div class="${className} p-2">${name}</div>`
      )
      ->Array.join("")
    
    `<div class="p-4 border rounded ${resolveBackgroundColor(Primary, theme)}">
      <h3 class="${resolveColor(Primary, theme)} font-bold">${info.name} Theme</h3>
      <div class="mt-2 space-y-1">
        ${colorSwatches}
      </div>
      <div class="mt-2 text-sm ${resolveColor(Tertiary, theme)}">
        High Contrast: ${info.accessibility.highContrast ? "Yes" : "No"}<br>
        Reduced Motion: ${info.accessibility.reducedMotion ? "Yes" : "No"}
      </div>
    </div>`
  }
}

// Performance optimizations
module Performance = {
  // Memoized theme resolution
  let cache = ref(Map.make())
  
  let memoizedResolveColor = (color: DS.color, theme: theme): string => {
    let key = `${color->Obj.magic}:${theme->Obj.magic}`
    switch cache.contents->Map.get(key) {
    | Some(result) => result
    | None => {
        let result = resolveColor(color, theme)
        cache.contents->Map.set(key, result)->ignore
        result
      }
    }
  }
  
  // Batch theme class generation
  let batchResolveColors = (colors: array<DS.color>, theme: theme): array<string> => {
    colors->Array.map(color => memoizedResolveColor(color, theme))
  }
  
  // Clear memoization cache
  let clearCache = (): unit => {
    cache := Map.make()
  }
}

// Export convenience functions
let resolveThemedColor = Performance.memoizedResolveColor
let createThemedComponent = ComponentHelpers.themedComponent
let generateThemeCSS = CSSVariables.generateThemeCSS
let getThemeTransitions = Transitions.getTransitionClasses