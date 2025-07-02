// Main entry point for AI-powered ReScript component generation system
// Exports the public API for the generation system

export { 
  ComponentRequest, 
  GenerationResult, 
  GenerationConfig, 
  ProjectContext,
  ReScriptExample,
  PatternStats 
} from './types.js';

export { ReScriptGenerator } from './rescript-generator.js';
export { PatternLearningSystem } from './pattern-learning.js';
export { ProjectAnalyzer } from './project-analyzer.js';
export { GeneratorCLI, runComponentGenerator } from './cli.js';

/**
 * TODO: High-level convenience function for quick component generation
 */
export async function generateReScriptComponent(
  description: string, 
  componentName: string
): Promise<string> {
  // TODO: Implement simple generation function
  // - Create default configuration
  // - Initialize generator with project analysis
  // - Generate component from description
  // - Return the generated ReScript code
  
  throw new Error('High-level component generation not implemented yet');
}

/**
 * TODO: Initialize the AI generation system for a project
 */
export async function initializeGenerationSystem(projectPath?: string): Promise<void> {
  // TODO: Implement system initialization
  // - Analyze the project structure
  // - Extract existing patterns
  // - Set up pattern learning system
  // - Prepare for component generation
  
  throw new Error('System initialization not implemented yet');
}