// STRICT: Type-safe HTML - eliminate all string-based tag matching
// Benefits: Autocomplete, compile-time verification, impossible states eliminated

type htmlTag = [
  | #h1 | #h2 | #h3 | #h4 | #h5 | #h6
  | #p | #span | #div | #section | #article | #main | #header | #footer
  | #label | #strong | #em | #small | #mark
  | #button | #a | #input | #textarea
]

type listTag = [#ul | #ol | #li]
type tableTag = [#table | #thead | #tbody | #tr | #th | #td]
type mediaTag = [#img | #video | #audio | #picture | #canvas | #svg]

// Helper to convert to string for React createElement
let tagToString = (tag: htmlTag): string => {
  switch tag {
  | #h1 => "h1" | #h2 => "h2" | #h3 => "h3" | #h4 => "h4" | #h5 => "h5" | #h6 => "h6"
  | #p => "p" | #span => "span" | #div => "div" 
  | #section => "section" | #article => "article" | #main => "main"
  | #header => "header" | #footer => "footer"
  | #label => "label" | #strong => "strong" | #em => "em" | #small => "small" | #mark => "mark"
  | #button => "button" | #a => "a" | #input => "input" | #textarea => "textarea"
  }
}

// Semantic constraints - only certain tags make sense for certain components
type headingTag = [#h1 | #h2 | #h3 | #h4 | #h5 | #h6]
type textTag = [#p | #span | #div | #label | #strong | #em | #small]
type interactiveTag = [#button | #a]

// Component-specific tag constraints
module Text = {
  type allowedTag = [headingTag | textTag]
  
  let isValidForStyle = (tag: allowedTag, style: DesignSystem.Typography.textStyle): bool => {
    switch (tag, style) {
    | (#h1 | #h2 | #h3, Display | Title | Heading) => true
    | (#p | #span | #div, Body | Subheading | Caption | Label) => true
    | (#label, Label) => true
    | (#strong | #em, Body | Caption) => true
    | _ => false
    }
  }
}

module Button = {
  type allowedTag = [#button | #a]
  
  let defaultTag = (href: option<string>): allowedTag => {
    switch href {
    | Some(_) => #a
    | None => #button
    }
  }
}