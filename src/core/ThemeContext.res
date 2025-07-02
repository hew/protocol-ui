// Theme Context System for React Components
// Provides theme state management and component integration

open Themes
module TC = ThemeCustomizer

// Enhanced theme context type with palette support
type themeContextValue = {
  currentTheme: theme,
  paletteConfig: option<TC.paletteThemeConfig>,
  setTheme: theme => unit,
  setPaletteTheme: TC.paletteThemeConfig => unit,
  toggleTheme: unit => unit,
  systemTheme: theme,
  userPreference: option<theme>,
}

// React context for theme
let themeContext = React.createContext({
  currentTheme: defaultTheme,
  paletteConfig: None,
  setTheme: _ => (),
  setPaletteTheme: _ => (),
  toggleTheme: () => (),
  systemTheme: defaultTheme,
  userPreference: None,
})

module Provider = {
  let makeProps = (~value, ~children, ()) => {
    "value": value,
    "children": children,
  }
  
  let make = React.Context.provider(themeContext)
}

// Enhanced theme provider component with palette support
module ThemeProvider = {
  @react.component
  let make = (~children, ~initialTheme: option<theme>=?, ~initialPaletteConfig: option<TC.paletteThemeConfig>=?) => {
    let (currentTheme, setCurrentTheme) = React.useState(() => 
      switch initialTheme {
      | Some(theme) => theme
      | None => Detection.getSystemTheme()
      }
    )
    
    let (paletteConfig, setPaletteConfig) = React.useState(() => initialPaletteConfig)
    let (systemTheme, _setSystemTheme) = React.useState(() => Detection.getSystemTheme())
    let (userPreference, setUserPreference) = React.useState(() => initialTheme)
    
    // Listen to system theme changes
    React.useEffect(() => {
      // In a real implementation, this would set up media query listeners
      // for prefers-color-scheme, prefers-contrast, etc.
      let cleanup = () => ()
      Some(cleanup)
    }, [])
    
    // Update current theme when preferences change
    React.useEffect(() => {
      let resolvedTheme = Detection.resolveTheme(
        ~userPreference?,
        ~systemPreference=?Some(systemTheme),
        ()
      )
      setCurrentTheme(_ => resolvedTheme)
      None
    }, (userPreference, systemTheme))
    
    // Apply theme classes to document (client-side only)
    React.useEffect(() => {
      // Simple client-side theme application
      if Js.typeof(Js.Undefined.return()) !== "undefined" {
        let themeClass = Classes.themeClasses(currentTheme)
        // For now, we'll skip the DOM manipulation to avoid %raw
        // This can be implemented later with proper DOM bindings
        Js.Console.log2("Theme changed to:", themeClass)
      }
      None
    }, [currentTheme])
    
    let setTheme = (theme: theme) => {
      setUserPreference(_ => Some(theme))
      // Update palette config theme mode if it exists
      switch paletteConfig {
      | Some(config) => setPaletteConfig(_ => Some({...config, mode: theme}))
      | None => ()
      }
      // Persist to localStorage (simplified for now)
      // localStorage persistence can be added later with proper bindings
      ()
    }
    
    let setPaletteTheme = (config: TC.paletteThemeConfig) => {
      setPaletteConfig(_ => Some(config))
      setCurrentTheme(_ => config.mode)
      setUserPreference(_ => Some(config.mode))
      // Persist palette config to localStorage (simplified for now)
      // localStorage persistence can be added later with proper bindings
      ()
    }
    
    let toggleTheme = () => {
      let newTheme = switch currentTheme {
      | Light => Dark
      | Dark => Light
      | HighContrast => Light
      | ReducedMotion => Light
      | Sepia => Light
      }
      setTheme(newTheme)
    }
    
    let contextValue = {
      currentTheme,
      paletteConfig,
      setTheme,
      setPaletteTheme,
      toggleTheme,
      systemTheme,
      userPreference,
    }
    
    <Provider value=contextValue>
      children
    </Provider>
  }
}

// Hook to use theme context
let useTheme = () => {
  React.useContext(themeContext)
}

// Enhanced typed record for themed style helpers with palette support
type themedStyle = {
  resolveColor: DesignSystem.color => string,
  resolveBackground: DesignSystem.color => string,
  resolveBorder: DesignSystem.color => string,
  resolveTypography: DesignSystem.Typography.textStyle => array<string>,
  getMotionClasses: unit => array<string>,
  shouldAnimate: unit => bool,
  // New palette-aware methods
  getColorClass: DesignSystem.color => string,
  getBackgroundClass: DesignSystem.color => string,
  getBorderClass: DesignSystem.color => string,
  isPaletteTheme: unit => bool,
  getPalette: unit => option<PaletteGenerator.palette>,
  // Required helpers for Text component refactor
  getTextColorClass: DesignSystem.color => string,
  getBgColorClass: DesignSystem.color => string,
}

// Enhanced hook for theme-aware styling with palette support
let useThemedStyle = (): themedStyle => {
  let {currentTheme, paletteConfig} = useTheme()
  
  // Choose resolution strategy based on whether we have a palette config
  let (resolveColorFn, resolveBackgroundFn, resolveBorderFn, paletteStyle) = switch paletteConfig {
  | Some(config) => {
      let paletteStyle = TC.createPaletteThemedStyle(config)
      (
        (color: DesignSystem.color) => paletteStyle.resolveColor(color),
        (color: DesignSystem.color) => paletteStyle.resolveBackground(color),
        (color: DesignSystem.color) => paletteStyle.resolveBorder(color),
        Some(paletteStyle)
      )
    }
  | None => (
      (color: DesignSystem.color) => Themes.resolveColor(color, currentTheme),
      (color: DesignSystem.color) => Themes.resolveBackgroundColor(color, currentTheme),
      (color: DesignSystem.color) => Themes.resolveBorderColor(color, currentTheme),
      None
    )
  }
  
  let resolveTypography = (style: DesignSystem.Typography.textStyle): array<string> => {
    Themes.Typography.resolveTextStyle(style, currentTheme)
  }
  
  let getMotionClasses = (): array<string> => {
    Themes.Motion.getMotionClasses(currentTheme)
  }
  
  let shouldAnimate = (): bool => {
    Themes.Motion.shouldAnimate(currentTheme)
  }
  
  // New palette-aware class generators
  let getColorClass = (color: DesignSystem.color): string => {
    switch paletteStyle {
    | Some(style) => style.getColorClass(color)
    | None => resolveColorFn(color) // fallback to hex color in arbitrary value class
    }
  }
  
  let getBackgroundClass = (color: DesignSystem.color): string => {
    switch paletteStyle {
    | Some(style) => style.getBackgroundClass(color)
    | None => resolveBackgroundFn(color)
    }
  }
  
  let getBorderClass = (color: DesignSystem.color): string => {
    switch paletteStyle {
    | Some(style) => style.getBorderClass(color)
    | None => resolveBorderFn(color)
    }
  }
  
  let isPaletteTheme = (): bool => {
    Option.isSome(paletteConfig)
  }
  
  let getPalette = (): option<PaletteGenerator.palette> => {
    paletteConfig->Option.map(config => config.palette)
  }
  
  // Required helpers for Text component refactor
  let getTextColorClass = (color: DesignSystem.color): string => {
    getColorClass(color)
  }
  
  let getBgColorClass = (color: DesignSystem.color): string => {
    getBackgroundClass(color)
  }
  
  {
    resolveColor: resolveColorFn,
    resolveBackground: resolveBackgroundFn,
    resolveBorder: resolveBorderFn,
    resolveTypography: resolveTypography,
    getMotionClasses: getMotionClasses,
    shouldAnimate: shouldAnimate,
    getColorClass: getColorClass,
    getBackgroundClass: getBackgroundClass,
    getBorderClass: getBorderClass,
    isPaletteTheme: isPaletteTheme,
    getPalette: getPalette,
    getTextColorClass: getTextColorClass,
    getBgColorClass: getBgColorClass,
  }
}

// HOC for theme-aware components
module ThemeAware = {
  type themedProps = {
    theme: theme,
    themedStyle: themedStyle,
  }
  
  let withTheme = (component: React.component<themedProps>) => {
    @react.component
    let make = () => {
      let themeContext = useTheme()
      let themedStyle = useThemedStyle()
      
      let themedProps = {
        theme: themeContext.currentTheme,
        themedStyle: themedStyle,
      }
      
      React.createElement(component, themedProps)
    }
    make
  }
}

// Utility components
module ThemeToggle = {
  @react.component
  let make = (~className: string="", ~children=?) => {
    let {currentTheme, toggleTheme} = useTheme()
    let themedStyle = useThemedStyle()
    
    let buttonClasses = DesignSystem.cx([
      "px-3 py-2 rounded-md transition-colors",
      themedStyle.resolveBackground(DesignSystem.Secondary),
      themedStyle.resolveColor(DesignSystem.Primary),
      "hover:" ++ themedStyle.resolveBackground(DesignSystem.Tertiary),
      ...themedStyle.getMotionClasses(),
      className,
    ])
    
    <button className=buttonClasses onClick={_ => toggleTheme()}>
      {switch children {
      | Some(content) => content
      | None => {
          let icon = switch currentTheme {
          | Light => "🌙"
          | Dark => "☀️"
          | _ => "🎨"
          }
          React.string(icon)
        }
      }}
    </button>
  }
}

// Theme selector dropdown
module ThemeSelector = {
  @react.component
  let make = (~className: string="") => {
    let {currentTheme, setTheme} = useTheme()
    let themedStyle = useThemedStyle()
    
    let selectClasses = DesignSystem.cx([
      "px-3 py-2 rounded-md border",
      themedStyle.getBackgroundClass(DesignSystem.Primary),
      themedStyle.getColorClass(DesignSystem.Primary),
      themedStyle.getBorderClass(DesignSystem.Primary),
      ...themedStyle.getMotionClasses(),
      className,
    ])
    
    let themeOptions = [
      (Light, "Light"),
      (Dark, "Dark"),
      (HighContrast, "High Contrast"),
      (ReducedMotion, "Reduced Motion"),
      (Sepia, "Sepia"),
    ]
    
    <select 
      className=selectClasses
      value={switch currentTheme {
      | Light => "light"
      | Dark => "dark"
      | HighContrast => "high-contrast"
      | ReducedMotion => "reduced-motion"
      | Sepia => "sepia"
      }}
      onChange={event => {
        let value = ReactEvent.Form.target(event)["value"]
        let newTheme = switch value {
        | "light" => Light
        | "dark" => Dark
        | "high-contrast" => HighContrast
        | "reduced-motion" => ReducedMotion
        | "sepia" => Sepia
        | _ => Light
        }
        setTheme(newTheme)
      }}>
      {themeOptions
       ->Array.map(((_theme, label)) => 
         <option key=label value={label->String.toLowerCase}>
           {React.string(label)}
         </option>
       )
       ->React.array}
    </select>
  }
}

// Palette theme configurator component
module PaletteThemeConfigurator = {
  type presetType = [#corporate | #vibrant | #balanced | #minimal | #custom]
  
  @react.component
  let make = (~className: string="", ~onConfigChange: option<TC.paletteThemeConfig => unit>=?) => {
    let {currentTheme, setPaletteTheme, paletteConfig} = useTheme()
    let themedStyle = useThemedStyle()
    
    let (brandColor, setBrandColor) = React.useState(() => "#2563eb")
    let (selectedPreset, setSelectedPreset) = React.useState(() => (#corporate: presetType))
    let (isExpanded, setIsExpanded) = React.useState(() => false)
    
    let containerClasses = DesignSystem.cx([
      "p-4 rounded-lg border",
      themedStyle.getBackgroundClass(DesignSystem.Secondary),
      themedStyle.getBorderClass(DesignSystem.Primary),
      className,
    ])
    
    let inputClasses = DesignSystem.cx([
      "px-3 py-2 rounded border",
      themedStyle.getBackgroundClass(DesignSystem.Primary),
      themedStyle.getColorClass(DesignSystem.Primary),
      themedStyle.getBorderClass(DesignSystem.Primary),
    ])
    
    let buttonClasses = DesignSystem.cx([
      "px-4 py-2 rounded font-medium",
      themedStyle.getBackgroundClass(DesignSystem.Primary),
      themedStyle.getColorClass(DesignSystem.Inverse),
      "hover:opacity-90",
      ...themedStyle.getMotionClasses(),
    ])
    
    let applyPaletteTheme = () => {
      // Parse the brand color
      switch ColorTheory.Utils.parse(brandColor) {
      | Some(color) => {
          let config = switch selectedPreset {
          | #corporate => TC.Presets.corporate(~brandColor=color, ~baseTheme=currentTheme, ())
          | #vibrant => TC.Presets.vibrant(~brandColor=color, ~baseTheme=currentTheme, ())
          | #balanced => TC.Presets.balanced(~brandColor=color, ~baseTheme=currentTheme, ())
          | #minimal => TC.Presets.minimal(~brandColor=color, ~baseTheme=currentTheme, ())
          | #custom => TC.createPaletteTheme(~brandColor=color, ~generationMode=#corporate, ~baseTheme=currentTheme, ())
          }
          setPaletteTheme(config)
          switch onConfigChange {
          | Some(callback) => callback(config)
          | None => ()
          }
        }
      | None => ()
      }
    }
    
    let resetToDefaultTheme = () => {
      // Reset to standard theme (no palette)
      // This would require updating the context to support clearing palette config
      Js.Console.log("Reset to default theme - implementation needed")
    }
    
    <div className=containerClasses>
      <div className="flex items-center justify-between mb-4">
        <h3 className={themedStyle.getColorClass(DesignSystem.Primary) ++ " font-semibold"}>
          {React.string("Color Palette Theme")}
        </h3>
        <button 
          className="text-sm underline"
          onClick={_ => setIsExpanded(prev => !prev)}>
          {React.string(isExpanded ? "Collapse" : "Configure")}
        </button>
      </div>
      
      {isExpanded ? 
        <div className="space-y-4">
          <div>
            <label className={themedStyle.getColorClass(DesignSystem.Secondary) ++ " block text-sm font-medium mb-2"}>
              {React.string("Brand Color")}
            </label>
            <div className="flex gap-2">
              <input
                type_="color"
                value=brandColor
                onChange={event => setBrandColor(ReactEvent.Form.target(event)["value"])}
                className={inputClasses ++ " w-16 h-10"}
              />
              <input
                type_="text"
                value=brandColor
                onChange={event => setBrandColor(ReactEvent.Form.target(event)["value"])}
                placeholder="#2563eb"
                className={inputClasses ++ " flex-1"}
              />
            </div>
          </div>
          
          <div>
            <label className={themedStyle.getColorClass(DesignSystem.Secondary) ++ " block text-sm font-medium mb-2"}>
              {React.string("Palette Style")}
            </label>
            <select
              className=inputClasses
              value={switch selectedPreset {
              | #corporate => "corporate"
              | #vibrant => "vibrant"
              | #balanced => "balanced"
              | #minimal => "minimal"
              | #custom => "custom"
              }}
              onChange={event => {
                let value = ReactEvent.Form.target(event)["value"]
                let preset = switch value {
                | "corporate" => #corporate
                | "vibrant" => #vibrant
                | "balanced" => #balanced
                | "minimal" => #minimal
                | "custom" => #custom
                | _ => #corporate
                }
                setSelectedPreset(_ => preset)
              }}>
              <option value="corporate">{React.string("Corporate - Professional & Accessible")}</option>
              <option value="vibrant">{React.string("Vibrant - Rich & Colorful")}</option>
              <option value="balanced">{React.string("Balanced - Complementary Harmony")}</option>
              <option value="minimal">{React.string("Minimal - Simple & Clean")}</option>
            </select>
          </div>
          
          <div className="flex gap-2">
            <button className=buttonClasses onClick={_ => applyPaletteTheme()}>
              {React.string("Apply Palette Theme")}
            </button>
            <button 
              className={buttonClasses ++ " opacity-70"}
              onClick={_ => resetToDefaultTheme()}>
              {React.string("Reset to Default")}
            </button>
          </div>
          
          {switch paletteConfig {
          | Some(config) => 
            <div className="mt-4 p-3 rounded bg-gray-50 dark:bg-gray-800">
              <p className="text-sm text-gray-600 dark:text-gray-400">
                {React.string("Active palette: " ++ config.palette.name)}
              </p>
            </div>
          | None => React.null
          }}
        </div>
      : React.null}
    </div>
  }
}