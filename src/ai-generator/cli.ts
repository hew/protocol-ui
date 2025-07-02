// CLI Interface for AI-powered ReScript component generation
// Provides interactive interface for generating components from natural language

import { ComponentRequest, GenerationConfig, ProjectContext } from './types.js';
import { ReScriptGenerator } from './rescript-generator.js';

/**
 * CLI interface for the ReScript component generator
 */
export class GeneratorCLI {
  private generator: ReScriptGenerator;

  constructor() {
    // Load configuration - using environment or defaults
    const config: GenerationConfig = {
      model: process.env.AI_MODEL || 'gpt-4',
      temperature: 0.1, // Low temperature for code generation
      maxTokens: 2000,
      usePatternLearning: true,
      exampleCount: 3
    };

    // Basic project context - will be enhanced by project analyzer
    const projectContext: ProjectContext = {
      designSystemPatterns: ['colorToClass', 'backgroundColorToClass', 'borderColorToClass'],
      existingComponents: ['Button', 'Input', 'Card', 'Modal', 'Grid', 'Container'],
      commonImports: ['open React', 'open DesignSystem', 'open TailwindTypes'],
      styleConventions: ['Use DesignSystem utilities', 'Tailwind through design system', 'Type-safe props']
    };

    this.generator = new ReScriptGenerator(config, projectContext);
  }

  /**
   * Main CLI entry point
   */
  async run(): Promise<void> {
    console.log('🤖 AI ReScript Component Generator\n');
    
    try {
      // 1. Initialize the generator
      console.log('Initializing AI generator...');
      await this.generator.initialize();
      
      // 2. Collect component requirements
      const request = await this.collectComponentRequest();
      
      // 3. Generate the component
      console.log('\n🎯 Generating ReScript component...');
      const result = await this.generator.generateComponent(request);
      
      // 4. Display results
      await this.displayResults(result);
      
      // 5. Offer to save if successful
      if (result.success) {
        const shouldSave = await this.promptYesNo('Save component to src/components/?');
        if (shouldSave) {
          await this.saveComponent(result.code, request.componentName);
        }
      }
      
      // 6. Collect feedback for learning
      await this.collectFeedback();
      
    } catch (error) {
      console.error('❌ Generation failed:', error);
      process.exit(1);
    }
  }

  /**
   * Prompt user for component description and options
   */
  private async collectComponentRequest(): Promise<ComponentRequest> {
    const { prompt } = await import('inquirer');

    const answers = await prompt([
      {
        type: 'input',
        name: 'description',
        message: 'Describe the component you want to generate:',
        validate: (input: string) => input.trim().length > 0 || 'Please provide a description'
      },
      {
        type: 'input',
        name: 'componentName',
        message: 'Component name (PascalCase):',
        validate: (input: string) => {
          if (!input.trim()) return 'Component name is required';
          if (!/^[A-Z][a-zA-Z0-9]*$/.test(input.trim())) {
            return 'Component name must be PascalCase (e.g., MyButton)';
          }
          return true;
        }
      },
      {
        type: 'list',
        name: 'styling',
        message: 'Styling approach:',
        choices: [
          { name: 'Styled (use DesignSystem utilities)', value: 'styled' },
          { name: 'Minimal (basic styling)', value: 'minimal' },
          { name: 'Custom (advanced styling)', value: 'custom' }
        ],
        default: 'styled'
      },
      {
        type: 'confirm',
        name: 'interactive',
        message: 'Does this component need interactive features (click, hover, etc.)?',
        default: false
      },
      {
        type: 'input',
        name: 'props',
        message: 'Props needed (comma-separated, optional):',
        filter: (input: string) => {
          if (!input.trim()) return undefined;
          return input.split(',').map(p => p.trim()).filter(p => p.length > 0);
        }
      }
    ]);

    return answers;
  }

  /**
   * Display generation results to user
   */
  private async displayResults(result: any): Promise<void> {
    if (result.success) {
      console.log('✅ Component generated successfully!\n');
      console.log('Generated ReScript code:');
      console.log('─'.repeat(50));
      console.log(result.code);
      console.log('─'.repeat(50));
      console.log(`\n📊 Confidence: ${Math.round(result.confidence * 100)}%`);
    } else {
      console.log('❌ Component generation failed\n');
      console.log('Compilation errors:');
      result.compilationErrors?.forEach((error: string) => {
        console.log(`  • ${error}`);
      });
      
      if (result.suggestions?.length > 0) {
        console.log('\n💡 Suggestions:');
        result.suggestions.forEach((suggestion: string) => {
          console.log(`  • ${suggestion}`);
        });
      }
      
      if (result.code) {
        console.log('\nGenerated code (with errors):');
        console.log('─'.repeat(50));
        console.log(result.code);
        console.log('─'.repeat(50));
      }
    }
  }

  /**
   * Save generated component to appropriate location
   */
  private async saveComponent(code: string, componentName: string): Promise<void> {
    const fs = await import('fs');
    const path = await import('path');

    try {
      const componentsDir = path.join(process.cwd(), 'src', 'components');
      const fileName = `${componentName}.res`;
      const filePath = path.join(componentsDir, fileName);

      // Ensure components directory exists
      if (!fs.existsSync(componentsDir)) {
        fs.mkdirSync(componentsDir, { recursive: true });
      }

      // Check if file already exists
      if (fs.existsSync(filePath)) {
        const overwrite = await this.promptYesNo(`${fileName} already exists. Overwrite?`);
        if (!overwrite) {
          console.log('Component not saved.');
          return;
        }
      }

      // Write the file
      fs.writeFileSync(filePath, code, 'utf8');
      console.log(`✅ Component saved to ${filePath}`);
      
      // Suggest next steps
      console.log('\n💡 Next steps:');
      console.log(`   1. Run: npx rescript`);
      console.log(`   2. Import in your app: import ${componentName} from './components/${componentName}.res'`);
      
    } catch (error) {
      console.error(`❌ Failed to save component: ${error}`);
    }
  }

  /**
   * Collect user feedback on generated component
   */
  private async collectFeedback(): Promise<{ rating: number; comments?: string }> {
    const { prompt } = await import('inquirer');

    try {
      const feedback = await prompt([
        {
          type: 'list',
          name: 'rating',
          message: 'How would you rate this generation?',
          choices: [
            { name: '⭐⭐⭐⭐⭐ Excellent', value: 5 },
            { name: '⭐⭐⭐⭐ Good', value: 4 },
            { name: '⭐⭐⭐ Average', value: 3 },
            { name: '⭐⭐ Poor', value: 2 },
            { name: '⭐ Very Poor', value: 1 }
          ]
        },
        {
          type: 'input',
          name: 'comments',
          message: 'Any additional comments (optional):',
          when: (answers: any) => answers.rating <= 3
        }
      ]);

      console.log('\n🙏 Thank you for your feedback! This helps improve the AI generation.');
      return feedback;
    } catch (error) {
      // User interrupted, skip feedback
      return { rating: 3 };
    }
  }

  /**
   * Simple yes/no prompt helper
   */
  private async promptYesNo(message: string): Promise<boolean> {
    const { prompt } = await import('inquirer');
    const answer = await prompt([{
      type: 'confirm',
      name: 'result',
      message
    }]);
    return answer.result;
  }

  /**
   * TODO: Show statistics and learning progress
   */
  private async showStats(): Promise<void> {
    // TODO: Implement statistics display
    // - Show generation success rate
    // - Display learned patterns
    // - Show improvement over time
    // - Display common failure modes
    
    throw new Error('Statistics display not implemented yet');
  }
}

/**
 * CLI entry point - can be called from package.json script
 */
export async function runComponentGenerator(): Promise<void> {
  try {
    const cli = new GeneratorCLI();
    await cli.run();
  } catch (error) {
    console.error('❌ Generation failed:', error);
    process.exit(1);
  }
}

// Auto-run if this is the main module
if (import.meta.url === `file://${process.argv[1]}`) {
  runComponentGenerator();
}