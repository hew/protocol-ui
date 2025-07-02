// Pure ReScript CLI for AI Component Generation
// Beautiful, type-safe, and functional

open ReScriptGenerator

// File system operations
@module("fs") @val
external writeFileSync: (string, string, string) => unit = "writeFileSync"

@module("fs") @val  
external existsSync: string => bool = "existsSync"

@module("fs") @val
external mkdirSync: (string, {"recursive": bool}) => unit = "mkdirSync"

@module("path") @val
external join: (string, string, string) => string = "join"

@module("path") @val
external dirname: string => string = "dirname"

// Console styling for beautiful output
let logSuccess = (msg: string): unit => Js.log(`✅ ${msg}`)
let logError = (msg: string): unit => Js.log(`❌ ${msg}`)
let logInfo = (msg: string): unit => Js.log(`💡 ${msg}`)
let logTitle = (msg: string): unit => {
  Js.log("")
  Js.log(`🤖 ${msg}`)
  Js.log("")
}

// -----------------------------------------------------------------------------
// Node process bindings (to replace %raw usages)
// -----------------------------------------------------------------------------

type nodeProcess

@val
external process: nodeProcess = "process"

@send
external cwd: nodeProcess => string = "cwd"

@send
external exit: (nodeProcess, int) => unit = "exit"

// -----------------------------------------------------------------------------
// Inquirer bindings – strongly-typed helpers to build questions & read answers
// -----------------------------------------------------------------------------

// Generic JS object for an Inquirer question
type question

// CLI prompts and user interaction
@module("inquirer") @val
external prompt: array<question> => Promise.t<'a> = "prompt"

@obj
external makeInputQuestion:
  (~type_: string, ~name: string, ~message: string, ~validate: (string => Js.Json.t)) =>
  question = ""

// Choice object type for list questions
type choice

@obj
external makeChoice: (~name: string, ~value: string) => choice = ""

@obj
external makeListQuestion:
  (~type_: string, ~name: string, ~message: string, ~choices: array<choice>, ~default: string) =>
  question = ""

@obj
external makeConfirmQuestion:
  (~type_: string, ~name: string, ~message: string, ~default: bool) =>
  question = ""

@obj
external makePropsQuestion:
  (~type_: string, ~name: string, ~message: string, ~filter: (string => Js.undefined<array<string>>)) => question = ""

// Answers object returned from Inquirer
type answers

@get external getDescription: answers => string = "description"
@get external getComponentName: answers => string = "componentName"
@get external getStyling: answers => string = "styling"
@get external getInteractive: answers => bool = "interactive"
@get external getProps: answers => Js.Nullable.t<array<string>> = "props"

// Answer for a simple confirm question
type yesNoAnswer

@get external getResult: yesNoAnswer => bool = "result"

// Prompt user for component requirements
let collectComponentRequest = async () => {
  try {
    // -----------------------------------------------------------------------
    // Build typed Inquirer questions
    // -----------------------------------------------------------------------

    // 1. Description
    let validateDescription = (input: string) =>
      if Js.String.trim(input)->Js.String.length > 0 {
        Obj.magic(true)
      } else {
        Obj.magic("Please provide a description")
      }

    let qDescription = makeInputQuestion(~type_="input", ~name="description", ~message="Describe the component you want to generate:", ~validate=validateDescription)

    // 2. Component name (PascalCase)
    let validateComponentName = (input: string) => {
      let trimmed = Js.String.trim(input)
      if trimmed == "" {
        Obj.magic("Component name is required")
      } else if Js.Re.test_(%re("/^[A-Z][a-zA-Z0-9]*$/"), trimmed) {
        Obj.magic(true)
      } else {
        Obj.magic("Component name must be PascalCase (e.g., MyButton)")
      }
    }

    let qComponentName = makeInputQuestion(~type_="input", ~name="componentName", ~message="Component name (PascalCase):", ~validate=validateComponentName)

    // 3. Styling list question
    let choices = [
      makeChoice(~name="Styled (use DesignSystem utilities)", ~value="styled"),
      makeChoice(~name="Minimal (basic styling)", ~value="minimal"),
      makeChoice(~name="Custom (advanced styling)", ~value="custom"),
    ]

    let qStyling = makeListQuestion(~type_="list", ~name="styling", ~message="Styling approach:", ~choices=choices, ~default="styled")

    // 4. Interactive confirm question
    let qInteractive = makeConfirmQuestion(~type_="confirm", ~name="interactive", ~message="Does this component need interactive features (click, hover, etc.)?", ~default=false)

    // 5. Props input with filter
    let filterProps = (input: string) => {
      let trimmed = Js.String.trim(input)
      if trimmed == "" {
        Js.undefined
      } else {
        trimmed
        ->Js.String2.split(",")
        ->Array.map(p => Js.String.trim(p))
        ->Array.filter(p => String.length(p) > 0)
        ->Js.Undefined.return
      }
    }

    let qProps = makePropsQuestion(~type_="input", ~name="props", ~message="Props needed (comma-separated, optional):", ~filter=filterProps)

    let questions = [qDescription, qComponentName, qStyling, qInteractive, qProps]

    let answers: answers = await prompt(questions)

    // Extract values with proper types
    let description = getDescription(answers)
    let componentName = getComponentName(answers)
    let stylingStr = getStyling(answers)
    let interactive = getInteractive(answers)
    let propsArray = getProps(answers)

    let styling = switch stylingStr {
    | "minimal" => #minimal
    | "styled" => #styled
    | "custom" => #custom
    | _ => #styled
    }

    let props = switch Js.Nullable.toOption(propsArray) {
    | None => None
    | Some(arr) => Some(arr)
    }

    let request: componentRequest = {
      description: description,
      componentName: componentName,
      styling: styling,
      interactive: interactive,
      props: props,
    }

    Ok(request)
  } catch {
  | exn => Error(`Failed to collect input: ${Js.Exn.message(Obj.magic(exn))->Option.getOr("Unknown error")}`)
  }
}

// Display generation results with beautiful formatting
let displayResults = (result: generationResult): unit => {
  if result.success {
    logSuccess("Component generated successfully!")
    Js.log("")
    Js.log("Generated ReScript code:")
    Js.log("─"->Js.String2.repeat(50))
    Js.log(result.code)
    Js.log("─"->Js.String2.repeat(50))
    Js.log(`📊 Confidence: ${(result.confidence *. 100.0)->Float.toString}%`)
  } else {
    logError("Component generation failed")
    Js.log("")
    Js.log("Compilation errors:")
    result.compilationErrors->Array.forEach(error => {
      Js.log(`  • ${error}`)
    })
    
    if result.suggestions->Array.length > 0 {
      Js.log("")
      logInfo("Suggestions:")
      result.suggestions->Array.forEach(suggestion => {
        Js.log(`  • ${suggestion}`)
      })
    }
    
    if result.code !== "" {
      Js.log("")
      Js.log("Generated code (with errors):")
      Js.log("─"->Js.String2.repeat(50))
      Js.log(result.code)
      Js.log("─"->Js.String2.repeat(50))
    }
  }
}

// Save component to file system
let saveComponent = async (code: string, componentName: string) => {
  try {
    let componentsDir = join(cwd(process), "src", "components")
    let fileName = `${componentName}.res`
    let filePath = join(componentsDir, fileName, "")
    
    // Ensure components directory exists
    if !existsSync(componentsDir) {
      mkdirSync(componentsDir, {"recursive": true})
    }
    
    // Check if file already exists
    if existsSync(filePath) {
      // For now, just overwrite - in future could prompt
      Js.log(`⚠️  ${fileName} already exists, overwriting...`)
    }
    
    // Write the file
    writeFileSync(filePath, code, "utf8")
    logSuccess(`Component saved to ${filePath}`)
    
    // Suggest next steps
    Js.log("")
    logInfo("Next steps:")
    Js.log(`   1. Run: npx rescript`)
    Js.log(`   2. Import in your app: open ${componentName}`)
    
    Ok()
  } catch {
  | exn => Error(`Failed to save component: ${Js.Exn.message(Obj.magic(exn))->Option.getOr("Unknown error")}`)
  }
}

// Simple yes/no prompt
let promptYesNo = async (message: string) => {
  try {
    let question = makeConfirmQuestion(~type_="confirm", ~name="result", ~message=message, ~default=false)
    let answer: yesNoAnswer = await prompt([question])
    getResult(answer)
  } catch {
  | _exn => false
  }
}

// Main CLI function - the orchestrator!
let runCLI = async () => {
  logTitle("AI ReScript Component Generator")
  
  try {
    // Initialize the generator
    Js.log("Initializing AI generator...")
    let generatorResult = createGenerator()
    
    let generator = switch generatorResult {
    | Error(error) => {
        logError(`Failed to create generator: ${error}`)
        exit(process, 1)
        // Unreachable, but satisfies type checker
        Obj.magic(None)
      }
    | Ok(gen) => {
        logSuccess("ReScript Generator initialized successfully")
        gen
      }
    }
    
    // Collect component requirements  
    let requestResult = await collectComponentRequest()
    let request = switch requestResult {
    | Error(error) => {
        logError(error)
        exit(process, 1)
        // This won't execute but satisfies type checker  
        Obj.magic(None)
      }
    | Ok(req) => req
    }
    
    // Generate the component
    Js.log("")
    Js.log("🎯 Generating ReScript component...")
    let result = await generateComponent(generator, request)
    
    // Display results
    Js.log("")
    displayResults(result)
    
    // Offer to save if successful
    if result.success {
      Js.log("")
      let shouldSave = await promptYesNo("Save component to src/components/?")
      if shouldSave {
        let saveResult = await saveComponent(result.code, request.componentName)
        switch saveResult {
        | Error(error) => logError(error)
        | Ok() => ()
        }
      }
    }
    
    // Collect feedback for learning (simplified for now)
    Js.log("")
    Js.log("🙏 Thank you for using the AI ReScript Generator!")
    
  } catch {
  | exn => {
      let errorMsg = Js.Exn.message(Obj.magic(exn))->Option.getOr("Unknown error")
      logError(`Generation failed: ${errorMsg}`)
      exit(process, 1)
    }
  }
}

// Export for use
let runComponentGenerator = runCLI