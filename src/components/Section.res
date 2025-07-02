// Clean Section Component - StyleProps System
// Page sections with unified design tokens

type variant = [
  | #Hero
  | #Regular
  | #Compact
]

@react.component
let make = (
  ~variant: variant = #Regular,
  ~styleProps: option<StyleProps.styleProps> = ?,
  ~children: React.element,
) => {
  let themedStyle = ThemeContext.useThemedStyle()
  
  // Get style props with defaults
  let stylePropsValue = styleProps->Option.getOr(StyleProps.empty)
  
  // Build variant classes
  let variantClasses = switch variant {
  | #Hero => [
      "py-16 sm:py-24 lg:py-32",
      themedStyle.getBgColorClass(DesignSystem.Primary) ++ " bg-opacity-5"
    ]
  | #Regular => [
      "py-12 sm:py-16"
    ]
  | #Compact => [
      "py-8 sm:py-12"
    ]
  }
  
  // Get classes from style props
  let styleClasses = StyleProps.toClasses(stylePropsValue)
  
  // Combine all classes
  let allClasses = Array.concat(variantClasses, styleClasses)
  let className = DesignSystem.cx(allClasses)
  
  <section className>
    {children}
  </section>
}