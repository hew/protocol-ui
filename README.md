# Protocol UI

> AI-generated components that follow your rules.

[![ReScript](https://img.shields.io/badge/ReScript-E6484F?style=for-the-badge&logo=rescript&logoColor=white)](https://rescript-lang.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![AI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com/)

## The Problem

Most AI code generation is unreliable. You get components with missing accessibility, broken patterns, and inconsistent styling. Each generation is a roll of the dice.

## The Solution

Instead of hoping AI understands your requirements, encode them as rules that cannot be violated. Generate components that always follow your patterns, use your design system, and include proper testing hooks.

```rescript
// Your rules, enforced automatically
let validateComponent = (code: string) => {
  // ✅ Must use design system functions
  // ✅ Must include test selectors  
  // ✅ Must have accessibility attributes
  // ❌ Cannot use direct CSS classes
}
```

## What You Get

- **Reliable generation** - Components that follow your coding standards every time
- **Design system integration** - No more `className="bg-blue-500"`, uses your design tokens  
- **Built-in testing** - Every component includes test selectors and accessibility attributes
- **ReScript/React focused** - Type-safe components that compile correctly

## Quick Start

```bash
git clone https://github.com/hew/protocol-ui
cd protocol-ui
npm install

# Add your OpenAI API key to .env
echo "OPENAI_API_KEY=your-key-here" > .env

# Generate a component
npm run generate:component
```

The CLI will prompt you for what you want to build:

```
? Describe the component: A button with primary and secondary variants
? Component name: ActionButton  
? Interactive features? Yes

✅ Generated ActionButton.res
```

## 📖 Example Output

### Input Prompt
```
"A card component with title, content, and optional action button"
```

### Generated ReScript Component
```rescript
// InfoCard.res
open React
open DesignSystem

type props = {
  title: string,
  content: string,
  actionText?: string,
  onAction?: unit => unit,
}

// Test selectors for Playwright
let selectors = {
  root: "[data-test-id='InfoCard']",
  title: "[data-test-id='InfoCard-title']",
  action: "[data-test-id='InfoCard-action']",
}

@react.component
let make = (~title, ~content, ~actionText=?, ~onAction=?) => {
  <div
    data-test-id="InfoCard"
    className={cx([
      "p-6", 
      "border", 
      "rounded-lg", 
      "shadow-sm",
      backgroundColorToClass(Surface)
    ])}>
    <h3 
      data-test-id="InfoCard-title"
      className={cx([
        "text-lg", 
        "font-semibold", 
        "mb-2",
        colorToClass(OnSurface)
      ])}>
      {title->React.string}
    </h3>
    <p 
      className={cx([
        "text-base", 
        "mb-4",
        colorToClass(OnSurfaceVariant)
      ])}>
      {content->React.string}
    </p>
    {switch (actionText, onAction) {
    | (Some(text), Some(handler)) =>
      <button
        data-test-id="InfoCard-action"
        className={cx([
          "px-4",
          "py-2", 
          "rounded",
          backgroundColorToClass(Primary),
          colorToClass(OnPrimary)
        ])}
        onClick={_ => handler()}
        aria-label={`Action: ${text}`}>
        {text->React.string}
      </button>
    | _ => React.null
    }}
  </div>
}
```

## How It Works

```
Input → AI Generation → Validation → ReScript Component
```

The system generates ReScript code, then validates it against your rules before saving. If validation fails, it tries again until it gets it right.

### Core Files

- **`src/ai-generator/ReScriptGenerator.res`** - AI generation logic
- **`scripts/theme.js`** - Automated color theming system  
- **`src/core/DesignSystem.res`** - Design system integration

## Validation Rules

Generated components must follow these patterns:

**Required:**
- Test IDs: `data-test-id="ComponentName"` 
- Design system: `backgroundColorToClass(Primary)` instead of `bg-blue-500`
- Accessibility: ARIA labels on interactive elements
- ReScript types: Proper type annotations

**Forbidden:**
- Direct CSS classes: `className="bg-blue-500"`
- Missing test hooks
- Poor accessibility

## Design System Integration

Uses your design tokens instead of hardcoded values:

```rescript
// ✅ Generated code uses design system
className={backgroundColorToClass(Primary)}
className={cx([colorToClass(OnSurface), "text-lg"])}

// ❌ Never generates direct classes  
className="bg-blue-500 text-white"  // Validation prevents this
```

Change your theme with one command:
```bash
node scripts/theme.js "#1f2937" corporate
```


## Testing Integration

Every generated component includes test selectors:

```rescript
// Auto-generated in every component
let selectors = {
  root: "[data-test-id='MyComponent']",
  button: "[data-test-id='MyComponent-button']",
}
```

Use them in your tests:
```rescript
// MyComponent.test.res
open Playwright

let testComponentClick = async () => {
  let page = await Page.create()
  await Page.click(page, MyComponent.selectors.button)
  await Expect.toBeVisible(Page.locator(page, MyComponent.selectors.root))
}
```

## Configuration

Set your OpenAI API key:
```bash
echo "OPENAI_API_KEY=your-key-here" > .env
```

## Development

```bash
npm run dev              # Start dev server
rescript -w              # Watch ReScript files
npm run generate:component # Generate a component
```

## License

MIT License - see [LICENSE](LICENSE) file for details.