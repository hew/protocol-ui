// Clean Button Component - StyleProps System
// Type-safe interactive buttons with unified design tokens

// Button variants - semantic button types
type variant = [
  | #Primary
  | #Secondary
  | #Ghost
  | #Success
  | #Warning
  | #Error
]

@react.component
let make = (
  ~variant: variant = #Primary,
  ~size: option<TailwindTypes.fontSize> = ?,
  ~disabled: bool = false,
  ~styleProps: option<StyleProps.styleProps> = ?,
  ~onClick: option<ReactEvent.Mouse.t => unit> = ?,
  ~children: React.element,
) => {
  // Get style props with defaults
  let stylePropsValue = styleProps->Option.getOr(StyleProps.empty)
  
  // Build variant classes using DesignSystem functions directly (simplified)
  let variantClasses = switch variant {
  | #Primary => [
      "px-4 py-2 rounded-md font-medium",
      DesignSystem.backgroundColorToClass(DesignSystem.Primary),
      DesignSystem.colorToClass(DesignSystem.Inverse),
      "hover:opacity-90",
      "focus:ring-2 focus:ring-offset-2 focus:ring-blue-500",
      "disabled:opacity-50 disabled:cursor-not-allowed",
      "transition-all duration-200"
    ]
  | #Secondary => [
      "px-4 py-2 rounded-md font-medium border",
      DesignSystem.backgroundColorToClass(DesignSystem.Secondary),
      DesignSystem.colorToClass(DesignSystem.Primary),
      DesignSystem.borderColorToClass(DesignSystem.Primary),
      "hover:bg-blue-50",
      "focus:ring-2 focus:ring-offset-2 focus:ring-blue-500",
      "disabled:opacity-50 disabled:cursor-not-allowed",
      "transition-all duration-200"
    ]
  | #Ghost => [
      "px-4 py-2 rounded-md font-medium",
      DesignSystem.colorToClass(DesignSystem.Primary),
      "hover:bg-gray-100",
      "focus:ring-2 focus:ring-offset-2 focus:ring-blue-500",
      "disabled:opacity-50 disabled:cursor-not-allowed",
      "transition-all duration-200"
    ]
  | #Success => [
      "px-4 py-2 rounded-md font-medium",
      DesignSystem.backgroundColorToClass(DesignSystem.Success),
      DesignSystem.colorToClass(DesignSystem.Inverse),
      "hover:opacity-90",
      "focus:ring-2 focus:ring-offset-2 focus:ring-green-500",
      "disabled:opacity-50 disabled:cursor-not-allowed",
      "transition-all duration-200"
    ]
  | #Warning => [
      "px-4 py-2 rounded-md font-medium",
      DesignSystem.backgroundColorToClass(DesignSystem.Warning),
      DesignSystem.colorToClass(DesignSystem.Inverse),
      "hover:opacity-90",
      "focus:ring-2 focus:ring-offset-2 focus:ring-amber-500",
      "disabled:opacity-50 disabled:cursor-not-allowed",
      "transition-all duration-200"
    ]
  | #Error => [
      "px-4 py-2 rounded-md font-medium",
      DesignSystem.backgroundColorToClass(DesignSystem.Error),
      DesignSystem.colorToClass(DesignSystem.Inverse),
      "hover:opacity-90",
      "focus:ring-2 focus:ring-offset-2 focus:ring-red-500",
      "disabled:opacity-50 disabled:cursor-not-allowed",
      "transition-all duration-200"
    ]
  }
  
  // Build size classes
  let sizeClasses = switch size {
  | Some(fontSize) => [StyleProps.sizeToClass(fontSize)]
  | None => []
  }
  
  // Get classes from style props
  let styleClasses = StyleProps.toClasses(stylePropsValue)
  
  // Combine all classes (motion is already included in variantClasses)
  let allClasses = Array.concat(Array.concat(variantClasses, sizeClasses), styleClasses)
  let className = DesignSystem.cx(allClasses)
  
  <button
    className
    disabled
    ?onClick>
    {children}
  </button>
}