// Component library index - Clean StyleProps system
// All components follow unified design token patterns

// Core Components
module Text = Text
module Button = Button
module Container = Container
module Section = Section

// Re-export StyleProps for convenience
module StyleProps = StyleProps

// Component creation helpers using StyleProps
module Create = {
  // Shorthand text creation with common patterns
  let heading = (~text, ~level: [#h1 | #h2 | #h3 | #h4] = #h2, ~color=?, ~styleProps=?) => {
    let tag = switch level {
    | #h1 => #h1
    | #h2 => #h2
    | #h3 => #h3
    | #h4 => #h4
    }
    let variant = switch level {
    | #h1 => Some(DesignSystem.Typography.Display)
    | #h2 => Some(DesignSystem.Typography.Title)
    | #h3 => Some(DesignSystem.Typography.Heading)
    | #h4 => Some(DesignSystem.Typography.Subheading)
    }
    
    <Text tag ?variant ?color ?styleProps>
      {React.string(text)}
    </Text>
  }
  
  let paragraph = (~text, ~color=?, ~styleProps=?) => {
    <Text variant=DesignSystem.Typography.Body ?color ?styleProps>
      {React.string(text)}
    </Text>
  }
  
  let label = (~text, ~color=?, ~styleProps=?) => {
    <Text tag=#label variant=DesignSystem.Typography.Label ?color ?styleProps>
      {React.string(text)}
    </Text>
  }
}