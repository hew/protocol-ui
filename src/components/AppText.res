// AppText.res
open DesignSystem

// Polymorphic variant types for type-safe props
type tag = [#h1 | #h2 | #h3 | #h4 | #h5 | #h6 | #p | #span | #div]
type size = [#xs | #sm | #base | #lg | #xl | #xl2 | #xl3 | #xl4 | #xl5]

// Test selectors for Playwright
let selectors = {
  "root": "[data-test-id='AppText']",
}

@react.component
let make = (~children, ~tag=#p, ~size=#base, ~color=Primary, ~className="") => {
  let sizeClass = switch size {
  | #xs => "text-xs"
  | #sm => "text-sm"
  | #base => "text-base"
  | #lg => "text-lg"
  | #xl => "text-xl"
  | #xl2 => "text-2xl"
  | #xl3 => "text-3xl"
  | #xl4 => "text-4xl"
  | #xl5 => "text-5xl"
  }
  
  let colorClass = colorToClass(color)
  let classes = cx([colorClass, sizeClass, className])
  
  switch tag {
  | #h1 => <h1 className=classes dataTestId="AppText">{children}</h1>
  | #h2 => <h2 className=classes dataTestId="AppText">{children}</h2>
  | #h3 => <h3 className=classes dataTestId="AppText">{children}</h3>
  | #h4 => <h4 className=classes dataTestId="AppText">{children}</h4>
  | #h5 => <h5 className=classes dataTestId="AppText">{children}</h5>
  | #h6 => <h6 className=classes dataTestId="AppText">{children}</h6>
  | #p => <p className=classes dataTestId="AppText">{children}</p>
  | #span => <span className=classes dataTestId="AppText">{children}</span>
  | #div => <div className=classes dataTestId="AppText">{children}</div>
  }
}