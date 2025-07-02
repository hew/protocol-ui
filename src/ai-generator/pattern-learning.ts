// Pattern Learning Module - DSPy-inspired approach for ReScript generation
// Learns from successful generations to improve future outputs

import { ReScriptExample, PatternStats, ProjectContext } from './types.js';

/**
 * Manages the collection and analysis of successful ReScript generation patterns
 */
export class PatternLearningSystem {
  private examples: ReScriptExample[] = [];
  private patterns: Map<string, number> = new Map();

  constructor(private projectContext: ProjectContext) {}

  /**
   * TODO: Implement pattern extraction from successful ReScript generations
   * Should analyze successful examples and extract common patterns like:
   * - Import statement patterns
   * - Component structure patterns  
   * - Props handling patterns
   * - Styling patterns using DesignSystem
   * - JSX element patterns
   */
  extractPatterns(example: ReScriptExample): string[] {
    // TODO: Implement pattern extraction algorithm
    // - Parse ReScript AST to identify structural patterns
    // - Extract common naming conventions
    // - Identify design system usage patterns
    // - Extract prop handling patterns
    throw new Error('Pattern extraction not implemented yet');
  }

  /**
   * Add a successful generation example to the learning corpus
   */
  addSuccessfulExample(example: ReScriptExample): void {
    // Store the example
    this.examples.push(example);
    
    // Extract and count patterns
    try {
      const patterns = this.extractPatterns(example);
      patterns.forEach(pattern => {
        const count = this.patterns.get(pattern) || 0;
        this.patterns.set(pattern, count + 1);
      });
    } catch (error) {
      console.warn('Pattern extraction failed:', error);
    }

    // Keep only the most recent 50 examples to avoid memory bloat
    if (this.examples.length > 50) {
      this.examples = this.examples.slice(-50);
    }
  }

  /**
   * Get the most relevant examples for few-shot learning
   * Uses simple keyword matching for now
   */
  getRelevantExamples(request: string, count: number = 3): ReScriptExample[] {
    if (this.examples.length === 0) return [];

    // Simple keyword-based relevance scoring
    const scored = this.examples.map(example => {
      const score = this.calculateRelevanceScore(request, example.request.description);
      return { example, score };
    });

    // Sort by relevance and return top examples
    return scored
      .sort((a, b) => b.score - a.score)
      .slice(0, count)
      .map(item => item.example);
  }

  /**
   * Calculate relevance score between request and example using keyword matching
   */
  private calculateRelevanceScore(request: string, exampleDescription: string): number {
    const requestWords = request.toLowerCase().split(/\s+/);
    const exampleWords = exampleDescription.toLowerCase().split(/\s+/);
    
    let matches = 0;
    requestWords.forEach(word => {
      if (exampleWords.includes(word) && word.length > 2) {
        matches++;
      }
    });

    return matches / Math.max(requestWords.length, 1);
  }

  /**
   * TODO: Generate optimized prompts based on learned patterns
   */
  generateOptimizedPrompt(request: string): string {
    // TODO: Implement prompt optimization
    // - Include most relevant examples
    // - Add discovered patterns as guidelines
    // - Include project-specific context
    // - Format for best ReScript generation results
    throw new Error('Prompt optimization not implemented yet');
  }

  /**
   * Analyze what patterns lead to compilation success vs failure
   */
  analyzeFailurePatterns(failedCode: string, errors: string[]): void {
    // Track common failure patterns for learning
    const failurePatterns = [];
    
    errors.forEach(error => {
      // Hard rule violations
      if (error.includes('HARD RULE VIOLATION')) {
        if (error.includes('Direct Tailwind className')) {
          failurePatterns.push('direct-tailwind-usage');
        }
        if (error.includes('Missing data-test-id')) {
          failurePatterns.push('missing-test-id');
        }
        if (error.includes('Missing exported test selectors')) {
          failurePatterns.push('missing-test-selectors');
        }
      }
      
      // Accessibility violations
      if (error.includes('ACCESSIBILITY VIOLATION')) {
        failurePatterns.push('accessibility-missing');
      }
      
      // ReScript compilation errors
      if (error.includes('Syntax error') || error.includes('Type error')) {
        failurePatterns.push('rescript-syntax-error');
      }
    });
    
    // Store failure patterns for improvement
    failurePatterns.forEach(pattern => {
      const count = this.patterns.get(`failure:${pattern}`) || 0;
      this.patterns.set(`failure:${pattern}`, count + 1);
    });
    
    console.log(`Tracked ${failurePatterns.length} failure patterns for learning`);
  }

  /**
   * TODO: Get statistics about learned patterns
   */
  getPatternStats(): PatternStats {
    // TODO: Implement statistics calculation
    return {
      totalAttempts: 0,
      successfulGenerations: 0,
      commonPatterns: [],
      failureReasons: []
    };
  }

  /**
   * Load pattern data from persistent storage
   */
  async loadPersistedPatterns(filePath: string): Promise<void> {
    const fs = await import('fs');
    const path = await import('path');

    try {
      if (!fs.existsSync(filePath)) return; // No saved patterns yet

      const data = fs.readFileSync(filePath, 'utf8');
      const parsed = JSON.parse(data);

      // Restore examples
      this.examples = parsed.examples || [];
      
      // Restore pattern frequency map
      this.patterns = new Map(parsed.patterns || []);

      console.log(`Loaded ${this.examples.length} examples and ${this.patterns.size} patterns`);
    } catch (error) {
      console.warn('Failed to load patterns:', error);
      // Continue with empty state
    }
  }

  /**
   * Save learned patterns to persistent storage
   */
  async savePatterns(filePath: string): Promise<void> {
    const fs = await import('fs');
    const path = await import('path');

    try {
      const data = {
        examples: this.examples,
        patterns: Array.from(this.patterns.entries()),
        savedAt: new Date().toISOString(),
        stats: this.getPatternStats()
      };

      // Ensure directory exists
      const dir = path.dirname(filePath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
      console.log(`Saved ${this.examples.length} examples and ${this.patterns.size} patterns`);
    } catch (error) {
      console.warn('Failed to save patterns:', error);
    }
  }
}