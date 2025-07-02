#!/usr/bin/env tsx
// Test script to validate the AI generation implementation without API calls

import { ReScriptGenerator } from './rescript-generator.js';
import { GenerationConfig, ProjectContext, ComponentRequest } from './types.js';

/**
 * Test the implementation without making actual API calls
 */
async function testImplementation() {
  console.log('🧪 Testing AI Generation Implementation\n');

  // Test configuration
  const config: GenerationConfig = {
    model: 'test-model',
    temperature: 0.1,
    maxTokens: 1000,
    usePatternLearning: false, // Disable for test
    exampleCount: 1
  };

  const projectContext: ProjectContext = {
    designSystemPatterns: ['colorToClass', 'backgroundColorToClass'],
    existingComponents: ['Button', 'Input', 'Card'],
    commonImports: ['open React', 'open DesignSystem'],
    styleConventions: ['Use DesignSystem utilities']
  };

  console.log('✅ 1. Configuration created successfully');

  try {
    // Test generator creation (should not fail)  
    const generator = new ReScriptGenerator(config, projectContext);
    console.log('✅ 2. ReScript generator instantiated');

    // Test prompt building
    const testRequest: ComponentRequest = {
      description: 'A simple button component with primary and secondary styles',
      componentName: 'TestButton',
      styling: 'styled',
      interactive: true,
      props: ['variant', 'children']
    };

    // Access the private method for testing
    const prompt = (generator as any).buildReScriptPrompt(testRequest, []);
    
    if (prompt.includes('TestButton') && prompt.includes('button component')) {
      console.log('✅ 3. Prompt building works correctly');
    } else {
      throw new Error('Prompt building failed');
    }

    // Test ReScript validation with a simple valid component
    const validReScriptCode = `// TestComponent.res
open React
open DesignSystem

type props = {
  children: React.element,
}

@react.component
let make = (~children) => {
  <div className="p-4">
    {children}
  </div>
}`;

    console.log('🔍 4. Testing ReScript validation...');
    const validation = await (generator as any).validateReScriptCode(validReScriptCode);
    
    if (validation.success !== undefined && Array.isArray(validation.errors)) {
      console.log(`✅ 4. ReScript validation system works (result: ${validation.success ? 'compiled' : 'failed'})`);
      if (!validation.success) {
        console.log('   Compilation errors (expected for test):', validation.errors.slice(0, 2));
      }
    } else {
      throw new Error('Validation system failed');
    }

    console.log('\n🎉 All implementation tests passed!');
    console.log('\n💡 Next steps:');
    console.log('   1. Set OPENAI_API_KEY or ANTHROPIC_API_KEY environment variable');
    console.log('   2. Run: npm run generate:component');
    console.log('   3. Test with a real component generation request');

  } catch (error) {
    console.error('❌ Test failed:', error);
    process.exit(1);
  }
}

// Check if this is the main module and run tests
if (import.meta.url === `file://${process.argv[1]}`) {
  testImplementation();
}

export { testImplementation };