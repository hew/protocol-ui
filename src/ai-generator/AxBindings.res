// Type-safe ReScript bindings to our Ax wrapper
// This is where TypeScript complexity dies and ReScript heaven begins

// Configuration for AI client
type aiConfig = {
  model: string,
  temperature: float,
  maxTokens: int,
}

// Result from AI generation
type generateResult = {
  text: string,
  success: bool,
  model: string,
  usage: option<Js.Json.t>,
  error: option<string>,
}

// AI client handle (opaque type for safety)
type aiClient

// External bindings to our JavaScript wrapper
@module("./ax-wrapper.js")
external createAIClient: aiConfig => aiClient = "createAIClient"

@module("./ax-wrapper.js")
external generateText: (aiClient, string) => Promise.t<generateResult> = "generateText"

// Helper function to create default config
let defaultConfig = (): aiConfig => {
  model: "gpt-4o-mini",
  temperature: 0.1,
  maxTokens: 2000,
}

// Safe wrapper for generation with error handling
let generateSafely = async (client: aiClient, prompt: string) => {
  try {
    let result = await generateText(client, prompt)

    if result.success {
      Ok(result.text)
    } else {
      let errorMsg = result.error->Option.getOr("Unknown AI generation error")
      Error(errorMsg)
    }
  } catch {
  | exn => {
      let message = switch Js.Exn.message(Obj.magic(exn)) {
      | Some(msg) => msg
      | None => "Unknown error"
      }
      Error(`AI generation failed: ${message}`)
    }
  }
}