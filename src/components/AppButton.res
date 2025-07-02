// AppButton.res
open DesignSystem

// Polymorphic variant types for type-safe props
type variant = [#primary | #secondary]

// Test selectors for Playwright
let selectors = {
  "root": "[data-test-id='AppButton']",
}

@react.component
let make = (~children, ~variant=#primary, ~disabled=false, ~onClick=?) => {
  let bgClass = switch variant {
  | #primary => backgroundColorToClass(Primary)
  | #secondary => backgroundColorToClass(Secondary)
  }
  
  let textClass = switch variant {
  | #primary => colorToClass(Inverse)  // White text on colored background
  | #secondary => colorToClass(Primary) // Colored text on transparent/white background
  }
  
  let classes = cx([bgClass, textClass, "px-6 py-3 rounded-sm"])
  
  <button 
    className=classes
    onClick={onClick->Option.getOr(_ => ())}
    disabled={disabled}
    dataTestId="AppButton"
    ariaLabel="Navigation button">
    {children}
  </button>
}