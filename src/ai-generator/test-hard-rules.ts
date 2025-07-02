#!/usr/bin/env tsx
// Test script to validate hard rules enforcement

import { ReScriptGenerator } from './rescript-generator.js';
import { GenerationConfig, ProjectContext } from './types.js';

/**
 * Test the hard rules validation system
 */
async function testHardRules() {
  console.log('🧪 Testing Hard Rules Validation\n');

  const config: GenerationConfig = {
    model: 'test-model',
    temperature: 0.1,
    maxTokens: 1000,
    usePatternLearning: false,
    exampleCount: 1
  };

  const projectContext: ProjectContext = {
    designSystemPatterns: [],
    existingComponents: [],
    commonImports: [],
    styleConventions: []
  };

  const generator = new ReScriptGenerator(config, projectContext);

  // Test cases with violations
  const testCases = [
    {
      name: 'Direct Tailwind className violation',
      code: `
        open React
        @react.component
        let make = () => {
          <div className="bg-blue-500 text-white p-4">
            {"Hello"}->React.string
          </div>
        }
      `,
      expectedViolations: ['Direct Tailwind className usage forbidden']
    },
    {
      name: 'Missing data-test-id violation',
      code: `
        open React
        open DesignSystem
        @react.component
        let make = () => {
          <div className={backgroundColorToClass(Primary)}>
            {"Hello"}->React.string
          </div>
        }
      `,
      expectedViolations: ['Missing data-test-id on outermost element']
    },
    {
      name: 'Missing test selectors violation',
      code: `
        open React
        open DesignSystem
        @react.component
        let make = () => {
          <div className={backgroundColorToClass(Primary)} data-test-id="test">
            {"Hello"}->React.string
          </div>
        }
      `,
      expectedViolations: ['Missing exported test selectors']
    },
    {
      name: 'Missing accessibility violation',
      code: `
        open React
        open DesignSystem
        let selectors = {root: "[data-test-id='test']"}
        @react.component
        let make = () => {
          <button className={backgroundColorToClass(Primary)} data-test-id="test" onClick={_ => ()}>
            {"Click me"}->React.string
          </button>
        }
      `,
      expectedViolations: ['Interactive elements missing ARIA labels']
    },
    {
      name: 'Perfect code - no violations',
      code: `
        open React
        open DesignSystem
        
        type variant = [#primary | #secondary]
        type props = {children: React.element, variant?: variant}
        
        let selectors = {
          root: "[data-test-id='PerfectButton']",
          button: "[data-test-id='PerfectButton-button']"
        }
        
        @react.component
        let make = (~children, ~variant=#primary) => {
          <button 
            className={backgroundColorToClass(Primary)}
            data-test-id="PerfectButton"
            aria-label="Perfect button component">
            {children}
          </button>
        }
      `,
      expectedViolations: []
    }
  ];

  let passed = 0;
  let failed = 0;

  for (const testCase of testCases) {
    console.log(`\n🔍 Testing: ${testCase.name}`);
    
    try {
      // Access private method for testing
      const validation = (generator as any).validateHardRules(testCase.code);
      
      const hasExpectedViolations = testCase.expectedViolations.every(expected =>
        validation.violations.some((violation: string) => violation.includes(expected))
      );
      
      const unexpectedViolations = validation.violations.filter((violation: string) =>
        !testCase.expectedViolations.some(expected => violation.includes(expected))
      );
      
      if (testCase.expectedViolations.length === 0) {
        // Should have no violations
        if (validation.success && validation.violations.length === 0) {
          console.log('   ✅ PASS: No violations detected (as expected)');
          passed++;
        } else {
          console.log('   ❌ FAIL: Unexpected violations found:', validation.violations);
          failed++;
        }
      } else {
        // Should have expected violations
        if (hasExpectedViolations) {
          console.log('   ✅ PASS: Expected violations detected');
          console.log('   📋 Violations found:');
          validation.violations.forEach((v: string) => console.log(`      • ${v}`));
          passed++;
        } else {
          console.log('   ❌ FAIL: Expected violations not detected');
          console.log('   📋 Expected:', testCase.expectedViolations);
          console.log('   📋 Actual:', validation.violations);
          failed++;
        }
      }
      
    } catch (error) {
      console.log(`   ❌ FAIL: Test error: ${error}`);
      failed++;
    }
  }

  console.log(`\n📊 Hard Rules Validation Results:`);
  console.log(`   ✅ Passed: ${passed}`);
  console.log(`   ❌ Failed: ${failed}`);

  if (failed === 0) {
    console.log('\n🎉 All hard rules validation tests passed!');
    console.log('🛡️ Your components will be bulletproof:');
    console.log('   • No direct Tailwind className usage');
    console.log('   • All components have test IDs');
    console.log('   • Accessibility requirements enforced');
    console.log('   • Dieter Rams principles upheld');
  } else {
    console.log('\n⚠️ Some validation tests failed. Check the implementation.');
    process.exit(1);
  }
}

// Run tests if this is the main module
if (import.meta.url === `file://${process.argv[1]}`) {
  testHardRules();
}

export { testHardRules };