// Clean Text Component - StyleProps System
// Type-safe typography with unified design tokens

open HtmlTypes

@react.component
let make = (
  ~tag: Text.allowedTag = #p,
  ~variant: option<DesignSystem.Typography.textStyle> = ?,
  ~color: option<DesignSystem.color> = ?,
  ~styleProps: option<StyleProps.styleProps> = ?,
  ~children: React.element,
) => {
  // Get style props with defaults
  let stylePropsValue = styleProps->Option.getOr(StyleProps.empty)
  
  // Build variant classes
  let variantClasses = switch variant {
  | Some(textStyle) => DesignSystem.Typography.textStyleToClasses(textStyle)
  | None => []
  }
  
  // Build individual property classes using DesignSystem directly
  let colorClass = color->Option.mapOr("", DesignSystem.colorToClass)
  let colorClasses = colorClass !== "" ? [colorClass] : []
  
  // Get classes from style props
  let styleClasses = StyleProps.toClasses(stylePropsValue)
  
  // Combine all classes
  let allClasses = Array.concat(Array.concat(variantClasses, colorClasses), styleClasses)
  let className = DesignSystem.cx(allClasses)
  
  // Type-safe HTML tag rendering
  switch tag {
  | #h1 => <h1 className> {children} </h1>
  | #h2 => <h2 className> {children} </h2>
  | #h3 => <h3 className> {children} </h3>
  | #h4 => <h4 className> {children} </h4>
  | #h5 => <h5 className> {children} </h5>
  | #h6 => <h6 className> {children} </h6>
  | #p => <p className> {children} </p>
  | #span => <span className> {children} </span>
  | #div => <div className> {children} </div>
  | #label => <label className> {children} </label>
  | #strong => <strong className> {children} </strong>
  | #em => <em className> {children} </em>
  | #small => <small className> {children} </small>
  }
}