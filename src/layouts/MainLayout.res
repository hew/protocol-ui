// Clean Main Layout - StyleProps System
// Main page layout with theme integration

// Layout uses DesignSystem and ThemeContext directly

@react.component
let make = (~children: React.element) => {
  let themedStyle = ThemeContext.useThemedStyle()
  
  let layoutClasses = DesignSystem.cx([
    "min-h-screen",
    themedStyle.getBgColorClass(DesignSystem.Primary) ++ " bg-opacity-5",
    themedStyle.getTextColorClass(DesignSystem.Primary),
    ...themedStyle.getMotionClasses()
  ])
  
  <div className=layoutClasses>
    <main>
      {children}
    </main>
  </div>
}