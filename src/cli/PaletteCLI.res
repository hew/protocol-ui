// CLI tool for color palette generation
// Usage: npm run palette -- --color "#2563eb" --mode corporate --output preview

module CT = ColorTheory
module PG = PaletteGenerator

// Node.js bindings
module NodeJs = {
  module Process = {
    @val external argv: array<string> = "process.argv"
    @val external exit: int => unit = "process.exit"
  }
  
  module Console = {
    @val external log: string => unit = "console.log"
    @val external error: string => unit = "console.error"
  }
}

// CLI argument types
type outputFormat = 
  | Tailwind
  | CSS
  | JSON
  | Preview

type cliArgs = {
  color: string,
  mode: [#corporate | #vibrant | #balanced | #minimal],
  output: outputFormat,
  name: option<string>,
  help: bool,
}

// Parse command line arguments
let parseArgs = (): cliArgs => {
  let argv = NodeJs.Process.argv
  let args = argv->Array.sliceToEnd(~start=2)
  
  let rec parseRec = (i: int, acc: cliArgs): cliArgs => {
    if i >= Array.length(args) {
      acc
    } else {
      switch args[i] {
      | Some("--color") => 
        switch args[i + 1] {
        | Some(color) => parseRec(i + 2, {...acc, color})
        | None => parseRec(i + 1, acc)
        }
      | Some("--mode") => 
        switch args[i + 1] {
        | Some(mode) => {
            let modeValue = switch mode {
            | "corporate" => #corporate
            | "vibrant" => #vibrant
            | "balanced" => #balanced
            | "minimal" => #minimal
            | _ => #corporate // default
            }
            parseRec(i + 2, {...acc, mode: modeValue})
          }
        | None => parseRec(i + 1, acc)
        }
      | Some("--output") => 
        switch args[i + 1] {
        | Some(output) => {
            let outputValue = switch output {
            | "tailwind" => Tailwind
            | "css" => CSS
            | "json" => JSON
            | "preview" => Preview
            | _ => Preview // default
            }
            parseRec(i + 2, {...acc, output: outputValue})
          }
        | None => parseRec(i + 1, acc)
        }
      | Some("--name") => 
        switch args[i + 1] {
        | Some(name) => parseRec(i + 2, {...acc, name: Some(name)})
        | None => parseRec(i + 1, acc)
        }
      | Some("--help") => parseRec(i + 1, {...acc, help: true})
      | _ => parseRec(i + 1, acc) // ignore unknown args
      }
    }
  }
  
  let defaultArgs = {
    color: "#2563eb",
    mode: #corporate,
    output: Preview,
    name: None,
    help: false,
  }
  
  parseRec(0, defaultArgs)
}

// Help text
let showHelp = (): unit => {
  let helpText = `
🎨 Color Palette Generator CLI

Usage: npm run palette -- [options]

Options:
  --color <hex>     Brand color in hex format (default: #2563eb)
  --mode <mode>     Palette generation mode:
                    - corporate: Professional, accessible palette
                    - vibrant: Rich, colorful palette with analogous colors
                    - balanced: Complementary color harmony
                    - minimal: Simple 5-color palette
                    (default: corporate)
  --output <format> Output format:
                    - preview: Console color preview (default)
                    - tailwind: Tailwind CSS configuration
                    - css: CSS custom properties
                    - json: JSON format
  --name <name>     Color name for exports (default: brand)
  --help            Show this help message

Examples:
  npm run palette -- --color "#ff6b6b" --mode vibrant
  npm run palette -- --color "#2563eb" --output tailwind --name primary
  npm run palette -- --color "#059669" --mode corporate --output css
`
  
  NodeJs.Console.log(helpText)
}

// ANSI color codes for terminal output
let ansiColor = (hex: string, text: string): string => {
  // Convert hex to RGB for ANSI
  switch CT.Convert.hexToRgb(hex) {
  | Ok(rgb) => {
      let r = rgb.r->Int.fromFloat
      let g = rgb.g->Int.fromFloat  
      let b = rgb.b->Int.fromFloat
      `\\x1b[48;2;${r->Int.toString};${g->Int.toString};${b->Int.toString}m${text}\\x1b[0m`
    }
  | Error(_) => text
  }
}

// Preview palette in terminal with colors
let showPreview = (palette: PG.palette): unit => {
  NodeJs.Console.log("\\n🎨 Generated Color Palette\\n")
  
  NodeJs.Console.log("Color Scale:")
  palette.scale->Array.forEach(entry => {
    let colorBlock = ansiColor(entry.hex, "    ")
    let weight = entry.weight->Int.toString
    let contrast = entry.contrastWithWhite->Js.Float.toFixedWithPrecision(~digits=2)
    let aa = entry.meetsAA_onWhite ? "✓ AA" : "✗ AA"
    
    let paddedWeight = weight->String.length == 2 ? weight ++ " " : weight ++ "  "
    NodeJs.Console.log(`${colorBlock} ${paddedWeight} ${entry.hex} (${contrast} ${aa})`)
  })
  
  switch palette.semanticColors {
  | Some(semantic) => {
      NodeJs.Console.log("\\nSemantic Colors:")
      let successHex = CT.Convert.toHex(semantic.success)
      let warningHex = CT.Convert.toHex(semantic.warning)
      let errorHex = CT.Convert.toHex(semantic.error)
      let infoHex = CT.Convert.toHex(semantic.info)
      
      NodeJs.Console.log(`${ansiColor(successHex, "    ")} Success ${successHex}`)
      NodeJs.Console.log(`${ansiColor(warningHex, "    ")} Warning ${warningHex}`)
      NodeJs.Console.log(`${ansiColor(errorHex, "    ")} Error   ${errorHex}`)
      NodeJs.Console.log(`${ansiColor(infoHex, "    ")} Info    ${infoHex}`)
    }
  | None => ()
  }
  
  NodeJs.Console.log("")
}

// Generate palette output
let generateOutput = (palette: PG.palette, format: outputFormat, colorName: string): unit => {
  switch format {
  | Preview => showPreview(palette)
  | Tailwind => {
      let config = PG.Utils.toTailwindConfig(palette, colorName)
      NodeJs.Console.log(config)
    }
  | CSS => {
      let css = PG.Utils.toCssVariables(palette, colorName)
      NodeJs.Console.log(css)
    }
  | JSON => {
      // Create JSON representation
      let scaleJson = palette.scale->Array.map(entry => {
        {
          "weight": entry.weight,
          "hex": entry.hex,
          "contrast": {
            "white": entry.contrastWithWhite,
            "black": entry.contrastWithBlack,
          },
          "accessibility": {
            "aa_on_white": entry.meetsAA_onWhite,
            "aa_on_black": entry.meetsAA_onBlack,
          }
        }
      })
      
      let semanticJson = switch palette.semanticColors {
      | Some(semantic) => Some({
          "success": CT.Convert.toHex(semantic.success),
          "warning": CT.Convert.toHex(semantic.warning),
          "error": CT.Convert.toHex(semantic.error),
          "info": CT.Convert.toHex(semantic.info),
        })
      | None => None
      }
      
      let paletteJson = {
        "name": palette.name,
        "baseColor": CT.Convert.toHex(palette.baseColor),
        "scale": scaleJson,
        "semanticColors": semanticJson,
      }
      
      NodeJs.Console.log(Js.Json.stringifyWithSpace(paletteJson->Obj.magic, 2))
    }
  }
}

// Main CLI function
let main = (): unit => {
  let args = parseArgs()
  
  if args.help {
    showHelp()
  } else {
    // Parse the color
    switch CT.Utils.parse(args.color) {
    | Some(brandColor) => {
        // Generate palette based on mode
        let palette = switch args.mode {
        | #corporate => PG.Presets.corporate(brandColor)
        | #vibrant => PG.Presets.vibrant(brandColor)
        | #balanced => PG.Presets.balanced(brandColor)
        | #minimal => PG.Presets.minimal(brandColor)
        }
        
        // Get color name
        let colorName = switch args.name {
        | Some(name) => name
        | None => "brand"
        }
        
        // Generate output
        generateOutput(palette, args.output, colorName)
      }
    | None => {
        NodeJs.Console.error(`Error: Invalid color format "${args.color}". Please use hex format like #ff6b6b`)
        NodeJs.Process.exit(1)
      }
    }
  }
}

// Run the main function
main()