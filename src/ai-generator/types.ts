// TypeScript types for AI-powered ReScript component generation
// This module defines the core types for our DSPy-like approach

/**
 * Represents a natural language description of a component to generate
 */
export interface ComponentRequest {
  description: string;
  componentName: string;
  props?: string[];
  styling?: 'minimal' | 'styled' | 'custom';
  interactive?: boolean;
}

/**
 * Represents an example of successful ReScript component generation
 * Used for few-shot learning and pattern optimization
 */
export interface ReScriptExample {
  request: ComponentRequest;
  generatedCode: string;
  compilationSuccess: boolean;
  usageNotes?: string;
}

/**
 * Configuration for the AI generation pipeline
 */
export interface GenerationConfig {
  model: string;
  temperature: number;
  maxTokens: number;
  usePatternLearning: boolean;
  exampleCount: number;
}

/**
 * Result of a component generation attempt
 */
export interface GenerationResult {
  code: string;
  success: boolean;
  compilationErrors?: string[];
  suggestions?: string[];
  confidence: number;
}

/**
 * Pattern learning statistics
 */
export interface PatternStats {
  totalAttempts: number;
  successfulGenerations: number;
  commonPatterns: string[];
  failureReasons: string[];
}

/**
 * ReScript project context for better generation
 */
export interface ProjectContext {
  designSystemPatterns: string[];
  existingComponents: string[];
  commonImports: string[];
  styleConventions: string[];
}