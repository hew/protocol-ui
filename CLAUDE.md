# ReScript AI Component Generator

## Overview

Protocol UI is a systematic AI-powered component generation system for ReScript/React projects. It features:

- **DSPy-inspired architecture** for component generation
- **Automated theming system** with one-command color switching
- **Type-safe validation** and ReScript compilation
- **Design system integration** with semantic color management

## Quick Start

### Theme System
Switch color schemes with one command:
```bash
node scripts/theme.js "#1f2937" corporate
node scripts/theme.js "#059669" emerald
```

### Development Commands
- `npm run dev` - start development server
- `rescript` - compile ReScript files
- `rescript -w` - watch mode for development
- `npm run build` - production build

### AI Component Generation
Generate components using the AI system:
```bash
node generate-component.js
```

## Architecture

### Core System (`src/core/`)
- `DesignSystem.res` - design tokens and color utilities
- `ThemeContext.res` - theme management
- `ColorPalette.res` - automated color palette generation
- `TailwindSafelist.res` - auto-generated Tailwind classes

### Components (`src/components/`)
- `AppText.res` - text component with semantic colors
- `AppButton.res` - button component with variants

### AI Generation System (`src/ai-generator/`)
- `ReScriptGenerator.res` - core generation logic
- Pattern learning and validation system

## ReScript Component Patterns

### Component Structure
```rescript
// Standard component pattern
@react.component
let make = (~children, ~variant=#primary, ~onClick=?) => {
  let classes = switch variant {
  | #primary => backgroundColorToClass(Primary)
  | #secondary => backgroundColorToClass(Secondary)
  }
  
  <button className=classes onClick={onClick->Option.getOr(_ => ())}>
    {children}
  </button>
}
```

### Dynamic HTML Elements
Use pattern matching for components that render different elements:

```rescript
@react.component
let make = (~children, ~tag=#p, ~color=Primary) => {
  let colorClass = colorToClass(color)
  
  switch tag {
  | #h1 => <h1 className=colorClass dataTestId="AppText">{children}</h1>
  | #h2 => <h2 className=colorClass dataTestId="AppText">{children}</h2>
  | #p => <p className=colorClass dataTestId="AppText">{children}</p>
  }
}
```

### Key Conventions
- Use `~prop` syntax for labeled arguments
- Access colors via `DesignSystem.colorToClass(Primary)`
- Use `dataTestId` (camelCase) for test attributes
- Pattern match with polymorphic variants: `[#primary | #secondary]`


## Important Implementation Notes

### Hard Rules for Promise Chains
1. **Never mix async/await with Promise.resolve wrapping**
2. **Let ReScript infer Promise return types** - avoid explicit `Promise.t<T>` in async functions  
3. **Use `await` outside switch expressions** - ReScript limitation requires: `let x = await fn(); switch x { ... }`
4. **Return values directly** in async function bodies
5. **Consistent error handling** - use Result pattern, not exceptions when possible

### Correct Async Pattern
```rescript
// ✅ CORRECT - Clean composition
let asyncFn = async () => {
  try {
    let result = await someOperation()
    Ok(result)  // Return directly
  } catch {
  | exn => Error("Failed")  // Return directly
  }
}
```

### Mathematical Foundation
This project demonstrates practical functional programming in ReScript:
- **Type-safe composition** without syntactic overhead
- **Mathematical thinking** for API design
- **Monadic patterns** using built-in Result types
- **Pure functions** with predictable composition

The approach balances mathematical rigor with practical accessibility.