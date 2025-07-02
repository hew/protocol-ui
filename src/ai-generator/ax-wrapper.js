// Minimal TypeScript wrapper for Ax framework
// This is the ONLY file that deals with Ax complexity
// Everything else will be pure ReScript

const { AxAIOpenAI, AxAIAnthropic } = require('@ax-llm/ax');

/**
 * Simple AI client wrapper
 * Hides all Ax complexity behind a clean interface
 */
class SimpleAIClient {
  constructor(config) {
    this.config = config;
    this.ai = null;
    this.initialized = false;
  }

  async initialize() {
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

      this.initialized = true;
    } catch (error) {
      throw new Error(`Failed to initialize AI client: ${error.message}`);
    }
  }

  async generate(prompt) {
    if (!this.initialized) {
      await this.initialize();
    }

    try {
      // Direct chat completion call - simpler than AxGen
      const response = await this.ai.chat([
        {
          role: 'user',
          content: prompt
        }
      ], {
        model: this.config.model || 'gpt-4o-mini',
        temperature: this.config.temperature || 0.1,
        max_tokens: this.config.maxTokens || 2000,
      });

      return {
        text: response.content || '',
        success: true,
        model: response.model || 'unknown',
        usage: response.usage || {}
      };
    } catch (error) {
      return {
        text: '',
        success: false,
        error: error.message,
        model: 'unknown',
        usage: {}
      };
    }
  }
}

// Factory function for ReScript bindings
function createAIClient(config) {
  return new SimpleAIClient(config);
}

// Simple generate function for ReScript
async function generateText(client, prompt) {
  return await client.generate(prompt);
}

// Export for ReScript bindings
module.exports = {
  createAIClient,
  generateText
};