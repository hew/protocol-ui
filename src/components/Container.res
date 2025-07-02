// Clean Container Component - StyleProps System
// Layout container with unified design tokens

@react.component
let make = (
  ~maxWidth: [#sm | #md | #lg | #xl | #full] = #lg,
  ~padding: bool = true,
  ~styleProps: option<StyleProps.styleProps> = ?,
  ~children: React.element,
) => {
  // Get style props with defaults
  let stylePropsValue = styleProps->Option.getOr(StyleProps.empty)
  
  // Build container classes
  let containerClasses = [
    "mx-auto",
    switch maxWidth {
    | #sm => "max-w-sm"
    | #md => "max-w-md" 
    | #lg => "max-w-4xl"
    | #xl => "max-w-6xl"
    | #full => "max-w-full"
    },
    padding ? "px-4 sm:px-6 lg:px-8" : ""
  ]->Array.filter(cls => cls !== "")
  
  // Get classes from style props
  let styleClasses = StyleProps.toClasses(stylePropsValue)
  
  // Combine all classes
  let allClasses = Array.concat(containerClasses, styleClasses)
  let className = DesignSystem.cx(allClasses)
  
  <div className>
    {children}
  </div>
}