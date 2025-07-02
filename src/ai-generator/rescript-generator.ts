// ReScript Component Generator - Core AI generation module
// Uses Ax framework for DSPy-inspired approach to generate type-safe ReScript components

import { AxAIOpenAI, AxAIAnthropic, AxGen } from '@ax-llm/ax';
import { ComponentRequest, GenerationResult, GenerationConfig, ProjectContext } from './types.js';
import { PatternLearningSystem } from './pattern-learning.js';

/**
 * Main class for AI-powered ReScript component generation
 * Implements DSPy-like optimization patterns using the Ax framework
 */
export class ReScriptGenerator {
  private patternLearner: PatternLearningSystem;
  private ai: AxAIOpenAI | AxAIAnthropic | null = null;
  private generator: AxGen | null = null;
  private initialized: boolean = false;

  constructor(
    private config: GenerationConfig,
    private projectContext: ProjectContext
  ) {
    this.patternLearner = new PatternLearningSystem(projectContext);
    // AI will be initialized in the initialize() method
  }

  /**
   * Initialize the Ax framework and load existing patterns
   */
  async initialize(): Promise<void> {
    if (this.initialized) return;

    try {
      // Initialize AI service based on available API keys
      if (process.env.OPENAI_API_KEY) {
        this.ai = new AxAIOpenAI({
          apiKey: process.env.OPENAI_API_KEY,
        });
      } else if (process.env.ANTHROPIC_API_KEY) {
        this.ai = new AxAIAnthropic({
          apiKey: process.env.ANTHROPIC_API_KEY,
        });
      } else {
        throw new Error('No API key found. Set OPENAI_API_KEY or ANTHROPIC_API_KEY environment variable.');
      }

      // Initialize the generator with the AI instance
      this.generator = new AxGen({
        ai: this.ai,
        model: this.config.model,
        temperature: this.config.temperature,
        maxTokens: this.config.maxTokens,
      });
      
      // Load any existing patterns
      try {
        await this.patternLearner.loadPersistedPatterns('./src/ai-generator/learned-patterns.json');
      } catch (error) {
        // No existing patterns file - that's ok for first run
        console.log('No existing patterns found, starting fresh');
      }

      this.initialized = true;
      console.log('✅ ReScript Generator initialized successfully');
    } catch (error) {
      throw new Error(`Failed to initialize ReScript Generator: ${error}`);
    }
  }

  /**
   * Generate a ReScript component from natural language description
   * Main entry point for component generation
   */
  async generateComponent(request: ComponentRequest): Promise<GenerationResult> {
    if (!this.initialized) {
      await this.initialize();
    }

    try {
      // 1. Get relevant examples from pattern learner
      const relevantExamples = this.config.usePatternLearning 
        ? this.patternLearner.getRelevantExamples(request.description, this.config.exampleCount)
        : [];

      // 2. Build optimized prompt with context and examples
      const prompt = this.buildReScriptPrompt(request, relevantExamples);

      // 3. Generate ReScript code using Ax
      if (!this.generator) throw new Error('Generator not initialized');
      
      const genResult = await this.generator.forward({ prompt });
      const generatedCode = genResult.text || genResult.response || '';

      // 4. Pre-validate against hard rules, then compile
      const ruleValidation = this.validateHardRules(generatedCode);
      if (!ruleValidation.success) {
        return {
          code: generatedCode,
          success: false,
          compilationErrors: ruleValidation.violations,
          suggestions: ['Fix hard rule violations before compilation'],
          confidence: 0.1
        };
      }

      const validation = await this.validateReScriptCode(generatedCode);

      // 5. Return results
      const result: GenerationResult = {
        code: generatedCode,
        success: validation.success,
        compilationErrors: validation.errors,
        suggestions: validation.success ? [] : ['Check ReScript syntax and imports'],
        confidence: validation.success ? 0.9 : 0.3
      };

      // Learn from this generation attempt
      await this.optimizeFromFeedback(request, generatedCode, validation.success, validation.errors);

      return result;
    } catch (error) {
      return {
        code: '',
        success: false,
        compilationErrors: [`Generation failed: ${error}`],
        suggestions: ['Check API key and network connection'],
        confidence: 0.0
      };
    }
  }

  /**
   * Build ReScript-specific prompt with project context and examples
   */
  private buildReScriptPrompt(request: ComponentRequest, examples: any[] = []): string {
    const basePrompt = `You are an expert ReScript developer creating type-safe React components.

TASK: Generate a ReScript component based on this description:
"${request.description}"

COMPONENT REQUIREMENTS:
- Component name: ${request.componentName}
- Styling approach: ${request.styling || 'styled'}
- Interactive features: ${request.interactive ? 'yes' : 'no'}
${request.props ? `- Props needed: ${request.props.join(', ')}` : ''}

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
4. Use ColorPalette if colors are needed: open ColorPalette
5. Component must be exported as default export
6. Use proper type annotations for props
7. Use JSX syntax with ReScript conventions
8. NEVER use className directly - use DesignSystem functions only
9. Always include comprehensive type definitions
10. Handle all interactive states (hover, focus, disabled, loading)

STYLING RULES:
- ✅ CORRECT: className={backgroundColorToClass(Primary)}
- ❌ FORBIDDEN: className="bg-blue-500"
- ✅ CORRECT: Use polymorphic variants for props: \`variant: [#primary | #secondary]\`
- ✅ CORRECT: Combine classes: cx([backgroundColorToClass(Primary), "px-4"])

TESTING REQUIREMENTS:
- Outermost element: data-test-id="{componentName}"
- Interactive elements: data-test-id="{componentName}-{action}"
- Export selectors: let selectors = {root: "[data-test-id='{componentName}']", ...}

ACCESSIBILITY RULES:
- Use semantic HTML elements (button, nav, main, etc.)
- Include ARIA labels for screen readers
- Ensure keyboard navigation works
- Maintain color contrast ratios
- Handle focus management

PERFORMANCE RULES:
- Avoid unnecessary useState for static content
- Use React.memo only when needed
- Minimize prop drilling
- Avoid inline object/function creation in JSX

PROJECT CONTEXT:
- Design system available: DesignSystem.colorToClass, backgroundColorToClass, borderColorToClass
- Color palette: Primary, Secondary, Success, Warning, Error, Info
- Styling: Use Tailwind classes ONLY through DesignSystem utilities
- Common imports: open TailwindTypes, open DesignSystem

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
  
  let sizeClasses = switch size {
  | #sm => "px-2 py-1 text-sm"
  | #md => "px-4 py-2"
  | #lg => "px-6 py-3 text-lg"
  }
  
  <button
    className={cx([baseClasses, variantClasses, sizeClasses])}
    disabled
    onClick={onClick->Belt.Option.getWithDefault(() => ())}
    data-test-id="${request.componentName}"
    aria-label="Action button">
    {children}
  </button>
}
\`\`\`

VALIDATION CHECKLIST:
- ✅ No direct className usage (only DesignSystem functions)
- ✅ data-test-id on outermost element
- ✅ Test selectors exported
- ✅ Polymorphic variants for type safety
- ✅ Accessibility attributes
- ✅ All interactive states handled
- ✅ Clean, minimal API (Dieter Rams principle)

${examples.length > 0 ? `
SUCCESSFUL EXAMPLES FROM THIS PROJECT:
${examples.map((ex, i) => `
Example ${i + 1} - ${ex.request?.description}:
\`\`\`rescript
${ex.generatedCode}
\`\`\`
`).join('\n')}
` : ''}

Generate ONLY the ReScript component code, no explanations:`;

    return basePrompt;
  }

  /**
   * Validate generated ReScript code by attempting compilation
   */
  private async validateReScriptCode(code: string): Promise<{ success: boolean; errors: string[] }> {
    const fs = await import('fs');
    const path = await import('path');
    const { execSync } = await import('child_process');
    const { randomUUID } = await import('crypto');

    const tempId = randomUUID();
    const tempDir = path.join(process.cwd(), 'temp-validation');
    const tempFile = path.join(tempDir, `TempComponent_${tempId}.res`);

    try {
      // Ensure temp directory exists
      if (!fs.existsSync(tempDir)) {
        fs.mkdirSync(tempDir, { recursive: true });
      }

      // Clean the generated code (remove markdown markers if any)
      const cleanCode = code
        .replace(/```rescript\n?/g, '')
        .replace(/```\n?/g, '')
        .trim();

      // Write generated code to temporary file
      fs.writeFileSync(tempFile, cleanCode, 'utf8');

      // Attempt to compile with ReScript
      try {
        // Run ReScript compiler on just this file
        execSync(`npx rescript build ${tempFile}`, {
          cwd: process.cwd(),
          stdio: 'pipe',
          timeout: 10000 // 10 second timeout
        });

        // If we get here, compilation succeeded
        return { success: true, errors: [] };

      } catch (compileError: any) {
        // Parse ReScript compilation errors
        const errorOutput = compileError.stderr?.toString() || compileError.stdout?.toString() || compileError.message;
        const errors = this.parseReScriptErrors(errorOutput);
        
        return { success: false, errors };
      }

    } catch (error: any) {
      return { 
        success: false, 
        errors: [`Validation setup failed: ${error.message}`] 
      };
    } finally {
      // Clean up temporary file
      try {
        if (fs.existsSync(tempFile)) {
          fs.unlinkSync(tempFile);
        }
        // Remove temp .mjs files that ReScript might generate
        const tempMjs = tempFile.replace('.res', '.res.mjs');
        if (fs.existsSync(tempMjs)) {
          fs.unlinkSync(tempMjs);
        }
      } catch (cleanup) {
        // Ignore cleanup errors
      }
    }
  }

  /**
   * Parse ReScript compiler error messages into structured format
   */
  private parseReScriptErrors(errorOutput: string): string[] {
    const errors: string[] = [];
    
    // Split by lines and look for error patterns
    const lines = errorOutput.split('\n');
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();
      
      // ReScript error patterns
      if (line.includes('Error:') || line.includes('Syntax error') || line.includes('Type error')) {
        errors.push(line);
        
        // Capture additional context lines
        for (let j = i + 1; j < Math.min(i + 3, lines.length); j++) {
          const contextLine = lines[j].trim();
          if (contextLine && !contextLine.startsWith('>') && contextLine.length < 100) {
            errors.push(`  ${contextLine}`);
          } else {
            break;
          }
        }
      }
    }

    // If no structured errors found, return the raw output (truncated)
    if (errors.length === 0 && errorOutput.trim()) {
      const truncated = errorOutput.length > 300 
        ? errorOutput.substring(0, 300) + '...'
        : errorOutput;
      errors.push(`Compilation failed: ${truncated}`);
    }

    return errors.length > 0 ? errors : ['Unknown compilation error'];
  }

  /**
   * Validate code against hard rules before compilation
   */
  private validateHardRules(code: string): { success: boolean; violations: string[] } {
    const violations: string[] = [];

    // Rule 1: No direct className with Tailwind classes
    const forbiddenClassNames = /className\s*=\s*"[^"]*(?:bg-|text-|border-|p-|m-|w-|h-|flex|grid)[^"]*"/g;
    const directClassNameMatches = code.match(forbiddenClassNames);
    if (directClassNameMatches) {
      violations.push(`🚫 HARD RULE VIOLATION: Direct Tailwind className usage forbidden: ${directClassNameMatches.join(', ')}`);
      violations.push('   ✅ FIX: Use DesignSystem functions like backgroundColorToClass(Primary)');
    }

    // Rule 2: Must have data-test-id on outermost element
    const hasDataTestId = /data-test-id\s*=\s*["{]/;
    if (!hasDataTestId.test(code)) {
      violations.push('🧪 HARD RULE VIOLATION: Missing data-test-id on outermost element');
      violations.push('   ✅ FIX: Add data-test-id={componentName} to outermost element');
    }

    // Rule 3: Must export test selectors
    const hasTestSelectors = /let\s+selectors\s*=|export\s+.*selectors/;
    if (!hasTestSelectors.test(code)) {
      violations.push('📤 HARD RULE VIOLATION: Missing exported test selectors');
      violations.push('   ✅ FIX: Export selectors object for Playwright tests');
    }

    // Additional validations for quality
    
    // Check for proper DesignSystem usage
    const hasDesignSystemImport = /open\s+DesignSystem/;
    if (!hasDesignSystemImport.test(code)) {
      violations.push('🎨 QUALITY VIOLATION: Missing DesignSystem import');
      violations.push('   ✅ FIX: Add "open DesignSystem" import');
    }

    // Check for polymorphic variants in type definitions
    const hasPolymorphicVariants = /\[#\w+(\s*\|\s*#\w+)*\]/;
    if (code.includes('type') && !hasPolymorphicVariants.test(code)) {
      violations.push('🔧 QUALITY RECOMMENDATION: Consider using polymorphic variants for props');
      violations.push('   💡 EXAMPLE: type variant = [#primary | #secondary]');
    }

    // Check for accessibility attributes
    const hasAriaLabel = /aria-label|aria-describedby|aria-labelledby/;
    const hasInteractiveElements = /button|input|select|textarea|onClick/;
    if (hasInteractiveElements.test(code) && !hasAriaLabel.test(code)) {
      violations.push('♿ ACCESSIBILITY VIOLATION: Interactive elements missing ARIA labels');
      violations.push('   ✅ FIX: Add aria-label or aria-describedby to interactive elements');
    }

    // Check for semantic HTML
    const hasSemanticHTML = /<(button|nav|main|section|article|header|footer|aside)/;
    const hasGenericDiv = /<div/;
    if (hasGenericDiv.test(code) && !hasSemanticHTML.test(code)) {
      violations.push('🏗️ SEMANTIC RECOMMENDATION: Consider using semantic HTML elements');
      violations.push('   💡 EXAMPLE: Use <button> instead of <div onClick={...}>');
    }

    return {
      success: violations.length === 0,
      violations
    };
  }

  /**
   * TODO: Extract project patterns from existing ReScript components
   */
  async analyzeProjectPatterns(): Promise<void> {
    // TODO: Implement project analysis
    // - Scan existing .res files in src/components/
    // - Extract common patterns (imports, component structure, etc.)
    // - Analyze DesignSystem usage patterns
    // - Build project context for better generation
    
    throw new Error('Project pattern analysis not implemented yet');
  }

  /**
   * Optimize generation based on success/failure feedback
   * This is where the DSPy-like learning happens
   */
  async optimizeFromFeedback(
    request: ComponentRequest, 
    generatedCode: string, 
    success: boolean, 
    errors?: string[]
  ): Promise<void> {
    if (!this.config.usePatternLearning) return;

    try {
      if (success) {
        // Add successful generation to pattern learner
        const example = {
          request,
          generatedCode,
          compilationSuccess: true,
          usageNotes: `Successfully generated ${request.componentName}`
        };
        
        await this.patternLearner.addSuccessfulExample(example);
      } else {
        // Analyze failure patterns
        await this.patternLearner.analyzeFailurePatterns(generatedCode, errors || []);
      }

      // Periodically save learned patterns
      if (Math.random() < 0.1) { // 10% chance to save
        await this.patternLearner.savePatterns('./src/ai-generator/learned-patterns.json');
      }
    } catch (error) {
      // Don't fail the whole generation if learning fails
      console.warn('Pattern learning failed:', error);
    }
  }

  /**
   * TODO: Generate multiple component variations and pick the best
   */
  async generateWithOptimization(request: ComponentRequest, iterations: number = 3): Promise<GenerationResult> {
    // TODO: Implement iterative optimization
    // - Generate multiple variations
    // - Test each for compilation success
    // - Use pattern learning to pick best approach
    // - Return the most successful generation
    
    throw new Error('Optimized generation not implemented yet');
  }

  /**
   * TODO: Export learned patterns for reuse
   */
  async exportLearnings(filePath: string): Promise<void> {
    // TODO: Implement learning export
    // - Save pattern learner state
    // - Export successful examples
    // - Save generation statistics
    // - Enable sharing learned patterns
    
    throw new Error('Learning export not implemented yet');
  }

  /**
   * TODO: Import previously learned patterns
   */
  async importLearnings(filePath: string): Promise<void> {
    // TODO: Implement learning import
    // - Load pattern learner state
    // - Import successful examples
    // - Restore generation optimizations
    // - Continue learning from previous state
    
    throw new Error('Learning import not implemented yet');
  }
}