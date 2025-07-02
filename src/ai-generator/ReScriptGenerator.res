// Pure ReScript AI Component Generator
// Type-safe, bulletproof, and beautifully functional

// Import our type-safe AI bindings
open AxBindings

// Component generation types
type componentRequest = {
  description: string,
  componentName: string,
  styling: [#minimal | #styled | #custom],
  interactive: bool,
  props: option<array<string>>,
}

type validationResult = {
  success: bool,
  violations: array<string>,
}

type generationResult = {
  code: string,
  success: bool,
  compilationErrors: array<string>,
  suggestions: array<string>,
  confidence: float,
}

// The main generator class - pure ReScript heaven!
type generator = {
  aiClient: aiClient,
  config: aiConfig,
}

// Create a new generator instance
let createGenerator = (): result<generator, string> => {
  let config = defaultConfig()
  let client = createAIClient(config)
  
  Ok({
    aiClient: client,
    config: config,
  })
}

// Build the ReScript generation prompt with all our hard rules
let buildPrompt = (request: componentRequest): string => {
  let propsText = request.props
    ->Option.map(props => `- Props needed: ${props->Array.join(", ")}`)
    ->Option.getOr("")
  
  let interactiveText = request.interactive ? "yes" : "no"
  let stylingText = switch request.styling {
  | #minimal => "minimal"
  | #styled => "styled" 
  | #custom => "custom"
  }

  `You are an expert ReScript developer creating type-safe React components.

TASK: Generate a ReScript component based on this description:
"${request.description}"

COMPONENT REQUIREMENTS:
- Component name: ${request.componentName}
- Styling approach: ${stylingText}
- Interactive features: ${interactiveText}
${propsText}

HARD RULES (NEVER VIOLATE):
1. 🚫 FORBIDDEN: className="tailwind-class" - Use ONLY DesignSystem variants
2. 🧪 REQUIRED: data-test-id on outermost element + interactive elements
3. 📤 REQUIRED: Export test selectors for Playwright
4. 🎨 REQUIRED: Follow Dieter Rams' 10 design principles

DIETER RAMS DESIGN PRINCIPLES:
- Innovative: Use modern patterns, avoid outdated approaches
- Useful: Every prop/feature must serve a clear purpose
- Aesthetic: Clean, minimal, visually harmonious
- Understandable: Self-explanatory interface, clear prop names
- Unobtrusive: Don't fight the design system, blend seamlessly
- Honest: Props do exactly what they say, no hidden behavior
- Long-lasting: Timeless patterns, avoid trendy solutions
- Detailed: Perfect spacing, typography, interactive states
- Environmentally friendly: Performant, no unnecessary re-renders
- As little design as possible: Minimal API, maximum impact

RESCRIPT CONSTRAINTS:
1. Use proper ReScript syntax with .res file format
2. Import React as: open React
3. Use DesignSystem module for styling: open DesignSystem
4. Component must be exported as default export
5. Use proper type annotations for props
6. NEVER use className directly - use DesignSystem functions only
7. Always include comprehensive type definitions
8. Handle all interactive states (hover, focus, disabled, loading)

STYLING RULES:
- ✅ CORRECT: className={backgroundColorToClass(Primary)}
- ❌ FORBIDDEN: className="bg-blue-500"
- ✅ CORRECT: Use polymorphic variants for props: variant: [#primary | #secondary]
- ✅ CORRECT: Combine classes: cx([backgroundColorToClass(Primary), "px-4"])

TESTING REQUIREMENTS:
- Outermost element: data-test-id="${request.componentName}"
- Interactive elements: data-test-id="${request.componentName}-{action}"
- Export selectors: let selectors = {root: "[data-test-id='${request.componentName}']", ...}

ACCESSIBILITY RULES:
- Use semantic HTML elements (button, nav, main, etc.)
- Include ARIA labels for screen readers
- Ensure keyboard navigation works
- Maintain color contrast ratios
- Handle focus management

EXAMPLE STRUCTURE:
\`\`\`rescript
// ${request.componentName}.res
open React
open DesignSystem

// Polymorphic variant types for type-safe props
type variant = [#primary | #secondary | #outline]
type size = [#sm | #md | #lg]

type props = {
  children: React.element,
  variant?: variant,
  size?: size,
  disabled?: bool,
  onClick?: unit => unit,
}

// Test selectors for Playwright
let selectors = {
  root: "[data-test-id='${request.componentName}']",
  button: "[data-test-id='${request.componentName}-button']",
}

@react.component
let make = (~children, ~variant=#primary, ~size=#md, ~disabled=false, ~onClick=?) => {
  // Use DesignSystem functions for styling - NEVER direct className
  let baseClasses = cx([
    backgroundColorToClass(Primary),
    colorToClass(Inverse),
    "px-4 py-2 rounded-sm"
  ])
  
  let variantClasses = switch variant {
  | #primary => backgroundColorToClass(Primary)
  | #secondary => backgroundColorToClass(Secondary) 
  | #outline => cx([borderColorToClass(Primary), "border bg-transparent"])
  }
  
  <button
    className={cx([baseClasses, variantClasses])}
    disabled
    onClick={onClick->Option.getWithDefault(() => ())}
    data-test-id="${request.componentName}"
    aria-label="Action button">
    {children}
  </button>
}
\`\`\`

Generate ONLY the ReScript component code, no explanations:`
}

// Validate generated code against hard rules
let validateHardRules = (code: string): validationResult => {
  let violations = []
  
  // Rule 1: No direct className with Tailwind classes
  let hasForbiddenClassName = Js.Re.test_(%re("/className\\s*=\\s*\"[^\"]*(?:bg-|text-|border-|p-|m-|w-|h-|flex|grid)[^\"]*\"/g"), code)
  if hasForbiddenClassName {
    violations->Array.push("🚫 HARD RULE VIOLATION: Direct Tailwind className usage forbidden")
    violations->Array.push("   ✅ FIX: Use DesignSystem functions like backgroundColorToClass(Primary)")
  }
  
  // Rule 2: Must have data-test-id
  let hasDataTestId = Js.Re.test_(%re("/data-test-id\\s*=\\s*[\"\\{]/"), code)
  if !hasDataTestId {
    violations->Array.push("🧪 HARD RULE VIOLATION: Missing data-test-id on outermost element")
    violations->Array.push("   ✅ FIX: Add data-test-id=\"{componentName}\" to outermost element")
  }
  
  // Rule 3: Must export test selectors
  let hasTestSelectors = Js.Re.test_(%re("/let\\s+selectors\\s*=/"), code)
  if !hasTestSelectors {
    violations->Array.push("📤 HARD RULE VIOLATION: Missing exported test selectors")
    violations->Array.push("   ✅ FIX: Export selectors object for Playwright tests")
  }
  
  // Accessibility check
  let hasInteractiveElements = Js.Re.test_(%re("/button|input|select|textarea|onClick/"), code)
  let hasAriaLabel = Js.Re.test_(%re("/aria-label|aria-describedby|aria-labelledby/"), code)
  if hasInteractiveElements && !hasAriaLabel {
    violations->Array.push("♿ ACCESSIBILITY VIOLATION: Interactive elements missing ARIA labels")
    violations->Array.push("   ✅ FIX: Add aria-label or aria-describedby to interactive elements")
  }
  
  {
    success: violations->Array.length === 0,
    violations: violations,
  }
}

// Generate a ReScript component - the main function!
let generateComponent = async (generator: generator, request: componentRequest) => {
  // Build the optimized prompt
  let prompt = buildPrompt(request)

  // Generate with AI using async/await
  let aiResult = await generateSafely(generator.aiClient, prompt)

  switch aiResult {
  | Error(error) => {
      success: false,
      code: "",
      compilationErrors: [`AI generation failed: ${error}`],
      suggestions: ["Check API key and network connection"],
      confidence: 0.0,
    }
  | Ok(generatedCode) => {
      // Clean the generated code
      let cleanCode = generatedCode
        ->Js.String2.replaceByRe(%re("/```rescript\\n?/g"), "")
        ->Js.String2.replaceByRe(%re("/```\\n?/g"), "")
        ->Js.String2.trim
      
      // Validate against hard rules first
      let ruleValidation = validateHardRules(cleanCode)
      
      if !ruleValidation.success {
        {
          success: false,
          code: cleanCode,
          compilationErrors: ruleValidation.violations,
          suggestions: ["Fix hard rule violations before compilation"],
          confidence: 0.1,
        }
      } else {
        // Rules passed! Return success
        {
          success: true,
          code: cleanCode,
          compilationErrors: [],
          suggestions: [],
          confidence: 0.9,
        }
      }
    }
  }
}