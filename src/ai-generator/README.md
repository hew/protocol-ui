# AI-Powered ReScript Component Generator

A DSPy-inspired system for generating type-safe ReScript components from natural language descriptions.

## Architecture

### Core Modules

- **`types.ts`** - TypeScript type definitions for the generation system
- **`rescript-generator.ts`** - Main AI generation engine using Ax framework
- **`pattern-learning.ts`** - DSPy-like pattern learning and optimization
- **`project-analyzer.ts`** - Extracts patterns from existing ReScript codebase
- **`cli.ts`** - Interactive command-line interface
- **`index.ts`** - Public API exports

### Key Features ✨

- 🤖 **Natural Language Input** - Describe components in plain English
- 🔒 **Type Safety** - Generates ReScript code with compile-time guarantees
- 📚 **Pattern Learning** - Learns from your project's existing patterns
- 🔄 **Iterative Optimization** - Improves over time using DSPy-like feedback loops
- 🎨 **Design System Integration** - Automatically uses your DesignSystem patterns
- ⚡ **Fast Generation** - Optimized prompts for reliable ReScript output

### Hard Rules Enforcement 🛡️

**NEVER VIOLATED:**
1. 🚫 **No Direct Tailwind** - `className="bg-blue-500"` is forbidden, use `backgroundColorToClass(Primary)`
2. 🧪 **Test IDs Required** - All components have `data-test-id` + exported selectors for Playwright
3. 🎨 **Dieter Rams Principles** - 10 principles of good design strictly enforced
4. ♿ **Accessibility First** - ARIA labels, semantic HTML, keyboard navigation
5. 🔧 **Polymorphic Variants** - Type-safe props with `[#primary | #secondary]` syntax

### Quality Enforcement 📐

- **Compilation Validation** - Code must compile or generation fails
- **Rule Pre-validation** - Checks hard rules before compilation
- **Accessibility Scanning** - Ensures ARIA labels and semantic HTML
- **Performance Patterns** - Prevents common React anti-patterns
- **Design System Compliance** - Only DesignSystem utilities allowed

## Usage 🚀

### Prerequisites
```bash
# Set your API key
export OPENAI_API_KEY="your-openai-key"
# OR
export ANTHROPIC_API_KEY="your-claude-key"
```

### CLI Interface
```bash
npm run generate:component
```

**Interactive prompts:**
- Component description (natural language)
- Component name (PascalCase)
- Styling approach (styled/minimal/custom)
- Interactive features needed
- Props specification

### Programmatic API
```typescript
import { generateReScriptComponent } from './src/ai-generator';

const code = await generateReScriptComponent(
  "A button component with primary and secondary variants",
  "ActionButton"
);
```

### Example Generation Session
```bash
$ npm run generate:component

🤖 AI ReScript Component Generator

Initializing AI generator...
✅ ReScript Generator initialized successfully

? Describe the component you want to generate: A loading spinner with different sizes
? Component name (PascalCase): LoadingSpinner  
? Styling approach: Styled (use DesignSystem utilities)
? Does this component need interactive features? No
? Props needed (comma-separated, optional): size, color

🎯 Generating ReScript component...
✅ Component generated successfully!

Generated ReScript code:
──────────────────────────────────────────────────
// LoadingSpinner.res
open React
open DesignSystem

type size = [#sm | #md | #lg]
type props = {
  size?: size,
  color?: [#primary | #secondary],
}

let selectors = {
  root: "[data-test-id='LoadingSpinner']"
}

@react.component
let make = (~size=#md, ~color=#primary) => {
  // Component implementation...
}
──────────────────────────────────────────────────

📊 Confidence: 90%
? Save component to src/components/? Yes
✅ Component saved to /path/to/src/components/LoadingSpinner.res

? How would you rate this generation? ⭐⭐⭐⭐⭐ Excellent

🙏 Thank you for your feedback! This helps improve the AI generation.
```

## How It Works ⚙️

1. **Project Analysis** - Scans existing `.res` files to understand your patterns
2. **Pattern Learning** - Builds a knowledge base of successful ReScript generations  
3. **AI Generation** - Uses Ax framework with optimized prompts to generate code
4. **Hard Rules Validation** - Pre-validates against design system and accessibility rules
5. **Compilation Validation** - Compiles generated code to ensure type safety
6. **Feedback Loop** - Learns from successes and failures to improve

## Implementation Status ✅

✅ **Core System** - Ax framework integration with OpenAI/Anthropic  
✅ **ReScript Generation** - Type-safe component generation with design system integration  
✅ **Hard Rules Enforcement** - Pre-compilation validation of design principles  
✅ **Pattern Learning** - DSPy-inspired learning from successful generations  
✅ **CLI Interface** - Interactive component generation with inquirer prompts  
✅ **Compilation Validation** - Real ReScript compiler integration with error parsing  
✅ **Test Suite** - Comprehensive validation of all systems  

🎯 **Ready for Production** - All core features implemented and tested

## Dependencies

- **@ax-llm/ax** - DSPy-inspired LLM framework for TypeScript
- **tsx** - TypeScript execution for CLI
- **ReScript** - Target language for generated components

## Project Context

This system is designed specifically for this ReScript marketing site template:
- Uses existing `DesignSystem.res` patterns
- Follows established component conventions
- Integrates with the color palette generation system
- Leverages Tailwind CSS through design system utilities