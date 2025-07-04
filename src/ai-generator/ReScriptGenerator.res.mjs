// Generated by ReScript, PLEASE EDIT WITH CARE

import * as AxBindings from "./AxBindings.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";

function createGenerator() {
  var config = AxBindings.defaultConfig();
  var client = AxBindings.createAIClient(config);
  return {
          TAG: "Ok",
          _0: {
            aiClient: client,
            config: config
          }
        };
}

function buildPrompt(request) {
  var propsText = Core__Option.getOr(Core__Option.map(request.props, (function (props) {
              return "- Props needed: " + props.join(", ");
            })), "");
  var interactiveText = request.interactive ? "yes" : "no";
  var match = request.styling;
  var stylingText = match === "styled" ? "styled" : (
      match === "custom" ? "custom" : "minimal"
    );
  return "You are an expert ReScript developer creating type-safe React components.\n\nTASK: Generate a ReScript component based on this description:\n\"" + request.description + "\"\n\nCOMPONENT REQUIREMENTS:\n- Component name: " + request.componentName + "\n- Styling approach: " + stylingText + "\n- Interactive features: " + interactiveText + "\n" + propsText + "\n\nHARD RULES (NEVER VIOLATE):\n1. 🚫 FORBIDDEN: className=\"tailwind-class\" - Use ONLY DesignSystem variants\n2. 🧪 REQUIRED: data-test-id on outermost element + interactive elements\n3. 📤 REQUIRED: Export test selectors for Playwright\n4. 🎨 REQUIRED: Follow Dieter Rams' 10 design principles\n\nDIETER RAMS DESIGN PRINCIPLES:\n- Innovative: Use modern patterns, avoid outdated approaches\n- Useful: Every prop/feature must serve a clear purpose\n- Aesthetic: Clean, minimal, visually harmonious\n- Understandable: Self-explanatory interface, clear prop names\n- Unobtrusive: Don't fight the design system, blend seamlessly\n- Honest: Props do exactly what they say, no hidden behavior\n- Long-lasting: Timeless patterns, avoid trendy solutions\n- Detailed: Perfect spacing, typography, interactive states\n- Environmentally friendly: Performant, no unnecessary re-renders\n- As little design as possible: Minimal API, maximum impact\n\nRESCRIPT CONSTRAINTS:\n1. Use proper ReScript syntax with .res file format\n2. Import React as: open React\n3. Use DesignSystem module for styling: open DesignSystem\n4. Component must be exported as default export\n5. Use proper type annotations for props\n6. NEVER use className directly - use DesignSystem functions only\n7. Always include comprehensive type definitions\n8. Handle all interactive states (hover, focus, disabled, loading)\n\nSTYLING RULES:\n- ✅ CORRECT: className={backgroundColorToClass(Primary)}\n- ❌ FORBIDDEN: className=\"bg-blue-500\"\n- ✅ CORRECT: Use polymorphic variants for props: variant: [#primary | #secondary]\n- ✅ CORRECT: Combine classes: cx([backgroundColorToClass(Primary), \"px-4\"])\n\nTESTING REQUIREMENTS:\n- Outermost element: data-test-id=\"" + request.componentName + "\"\n- Interactive elements: data-test-id=\"" + request.componentName + "-{action}\"\n- Export selectors: let selectors = {root: \"[data-test-id='" + request.componentName + "']\", ...}\n\nACCESSIBILITY RULES:\n- Use semantic HTML elements (button, nav, main, etc.)\n- Include ARIA labels for screen readers\n- Ensure keyboard navigation works\n- Maintain color contrast ratios\n- Handle focus management\n\nEXAMPLE STRUCTURE:\n\`\`\`rescript\n// " + request.componentName + ".res\nopen React\nopen DesignSystem\n\n// Polymorphic variant types for type-safe props\ntype variant = [#primary | #secondary | #outline]\ntype size = [#sm | #md | #lg]\n\ntype props = {\n  children: React.element,\n  variant?: variant,\n  size?: size,\n  disabled?: bool,\n  onClick?: unit => unit,\n}\n\n// Test selectors for Playwright\nlet selectors = {\n  root: \"[data-test-id='" + request.componentName + "']\",\n  button: \"[data-test-id='" + request.componentName + "-button']\",\n}\n\n@react.component\nlet make = (~children, ~variant=#primary, ~size=#md, ~disabled=false, ~onClick=?) => {\n  // Use DesignSystem functions for styling - NEVER direct className\n  let baseClasses = cx([\n    backgroundColorToClass(Primary),\n    colorToClass(Inverse),\n    \"px-4 py-2 rounded-sm\"\n  ])\n  \n  let variantClasses = switch variant {\n  | #primary => backgroundColorToClass(Primary)\n  | #secondary => backgroundColorToClass(Secondary) \n  | #outline => cx([borderColorToClass(Primary), \"border bg-transparent\"])\n  }\n  \n  <button\n    className={cx([baseClasses, variantClasses])}\n    disabled\n    onClick={onClick->Option.getWithDefault(() => ())}\n    data-test-id=\"" + request.componentName + "\"\n    aria-label=\"Action button\">\n    {children}\n  </button>\n}\n\`\`\`\n\nGenerate ONLY the ReScript component code, no explanations:";
}

function validateHardRules(code) {
  var violations = [];
  var hasForbiddenClassName = /className\\s*=\\s*\"[^\"]*(?:bg-|text-|border-|p-|m-|w-|h-|flex|grid)[^\"]*\"/g.test(code);
  if (hasForbiddenClassName) {
    violations.push("🚫 HARD RULE VIOLATION: Direct Tailwind className usage forbidden");
    violations.push("   ✅ FIX: Use DesignSystem functions like backgroundColorToClass(Primary)");
  }
  var hasDataTestId = /data-test-id\\s*=\\s*[\"\\{]/.test(code);
  if (!hasDataTestId) {
    violations.push("🧪 HARD RULE VIOLATION: Missing data-test-id on outermost element");
    violations.push("   ✅ FIX: Add data-test-id=\"{componentName}\" to outermost element");
  }
  var hasTestSelectors = /let\\s+selectors\\s*=/.test(code);
  if (!hasTestSelectors) {
    violations.push("📤 HARD RULE VIOLATION: Missing exported test selectors");
    violations.push("   ✅ FIX: Export selectors object for Playwright tests");
  }
  var hasInteractiveElements = /button|input|select|textarea|onClick/.test(code);
  var hasAriaLabel = /aria-label|aria-describedby|aria-labelledby/.test(code);
  if (hasInteractiveElements && !hasAriaLabel) {
    violations.push("♿ ACCESSIBILITY VIOLATION: Interactive elements missing ARIA labels");
    violations.push("   ✅ FIX: Add aria-label or aria-describedby to interactive elements");
  }
  return {
          success: violations.length === 0,
          violations: violations
        };
}

async function generateComponent(generator, request) {
  var prompt = buildPrompt(request);
  var aiResult = await AxBindings.generateSafely(generator.aiClient, prompt);
  if (aiResult.TAG !== "Ok") {
    return {
            code: "",
            success: false,
            compilationErrors: ["AI generation failed: " + aiResult._0],
            suggestions: ["Check API key and network connection"],
            confidence: 0.0
          };
  }
  var cleanCode = aiResult._0.replace(/```rescript\\n?/g, "").replace(/```\\n?/g, "").trim();
  var ruleValidation = validateHardRules(cleanCode);
  if (ruleValidation.success) {
    return {
            code: cleanCode,
            success: true,
            compilationErrors: [],
            suggestions: [],
            confidence: 0.9
          };
  } else {
    return {
            code: cleanCode,
            success: false,
            compilationErrors: ruleValidation.violations,
            suggestions: ["Fix hard rule violations before compilation"],
            confidence: 0.1
          };
  }
}

export {
  createGenerator ,
  buildPrompt ,
  validateHardRules ,
  generateComponent ,
}
/* AxBindings Not a pure module */
