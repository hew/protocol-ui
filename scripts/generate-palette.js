#!/usr/bin/env node

const inquirer = require('inquirer').default;
const fs = require('fs');
const path = require('path');

// Color format conversion helpers - TODO: Implement these functions
// Implement RGB to hex conversion (e.g. "rgb(255, 107, 53)" -> "#ff6b35")
function rgbToHex(rgb) {
  // Parse rgb(r, g, b) format
  const match = rgb.match(/rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)/);
  
  if (!match) {
    throw new Error('Invalid RGB format. Expected: rgb(r, g, b)');
  }
  
  const [, r, g, b] = match;
  
  // Convert to numbers and validate range
  const red = parseInt(r, 10);
  const green = parseInt(g, 10);
  const blue = parseInt(b, 10);
  
  if (red < 0 || red > 255 || green < 0 || green > 255 || blue < 0 || blue > 255) {
    throw new Error('RGB values must be between 0 and 255');
  }
  
  // Convert to hex with zero padding
  const toHex = (num) => num.toString(16).padStart(2, '0');
  
  return `#${toHex(red)}${toHex(green)}${toHex(blue)}`;
}

// Implement HSL to hex conversion (e.g. "hsl(14, 100%, 60%)" -> "#ff6b35") 
function hslToHex(hsl) {
  // Parse hsl(h, s%, l%) format
  const match = hsl.match(/hsl\(\s*(\d{1,3})\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%\s*\)/);
  
  if (!match) {
    throw new Error('Invalid HSL format. Expected: hsl(h, s%, l%)');
  }
  
  const [, h, s, l] = match;
  
  // Convert to numbers and normalize
  let hue = parseInt(h, 10) % 360; // Hue wraps around at 360
  const saturation = parseInt(s, 10) / 100; // Convert percentage to decimal
  const lightness = parseInt(l, 10) / 100; // Convert percentage to decimal
  
  if (saturation < 0 || saturation > 1 || lightness < 0 || lightness > 1) {
    throw new Error('HSL saturation and lightness must be between 0% and 100%');
  }
  
  // HSL to RGB conversion algorithm
  const c = (1 - Math.abs(2 * lightness - 1)) * saturation;
  const x = c * (1 - Math.abs(((hue / 60) % 2) - 1));
  const m = lightness - c / 2;
  
  let r, g, b;
  
  if (hue >= 0 && hue < 60) {
    [r, g, b] = [c, x, 0];
  } else if (hue >= 60 && hue < 120) {
    [r, g, b] = [x, c, 0];
  } else if (hue >= 120 && hue < 180) {
    [r, g, b] = [0, c, x];
  } else if (hue >= 180 && hue < 240) {
    [r, g, b] = [0, x, c];
  } else if (hue >= 240 && hue < 300) {
    [r, g, b] = [x, 0, c];
  } else {
    [r, g, b] = [c, 0, x];
  }
  
  // Convert to 0-255 range
  const red = Math.round((r + m) * 255);
  const green = Math.round((g + m) * 255);
  const blue = Math.round((b + m) * 255);
  
  // Convert to hex with zero padding
  const toHex = (num) => num.toString(16).padStart(2, '0');
  
  return `#${toHex(red)}${toHex(green)}${toHex(blue)}`;
}

// Implement named color to hex conversion (e.g. "red" -> "#ff0000")
function namedColorToHex(colorName) {
  // CSS named colors map (common subset)
  const namedColors = {
    // Basic colors
    'black': '#000000',
    'white': '#ffffff',
    'red': '#ff0000',
    'green': '#008000',
    'blue': '#0000ff',
    'yellow': '#ffff00',
    'orange': '#ffa500',
    'purple': '#800080',
    'pink': '#ffc0cb',
    'brown': '#a52a2a',
    'gray': '#808080',
    'grey': '#808080',
    
    // Extended colors
    'darkred': '#8b0000',
    'darkgreen': '#006400',
    'darkblue': '#00008b',
    'lightblue': '#add8e6',
    'lightgreen': '#90ee90',
    'lightgray': '#d3d3d3',
    'lightgrey': '#d3d3d3',
    'darkgray': '#a9a9a9',
    'darkgrey': '#a9a9a9',
    
    // Web-safe colors
    'lime': '#00ff00',
    'cyan': '#00ffff',
    'magenta': '#ff00ff',
    'maroon': '#800000',
    'navy': '#000080',
    'olive': '#808000',
    'teal': '#008080',
    'silver': '#c0c0c0',
    'aqua': '#00ffff',
    'fuchsia': '#ff00ff',
    
    // Popular named colors
    'crimson': '#dc143c',
    'gold': '#ffd700',
    'indigo': '#4b0082',
    'coral': '#ff7f50',
    'salmon': '#fa8072',
    'violet': '#ee82ee',
    'turquoise': '#40e0d0',
    'khaki': '#f0e68c',
    'plum': '#dda0dd',
    'tan': '#d2b48c'
  };
  
  const normalizedName = colorName.toLowerCase().trim();
  
  if (namedColors[normalizedName]) {
    return namedColors[normalizedName];
  }
  
  throw new Error(`Unknown color name: "${colorName}". Supported colors: ${Object.keys(namedColors).join(', ')}`);
}

// Validate hex color format
function isValidHexColor(color) {
  return /^#[0-9A-Fa-f]{6}$/.test(color);
}

// Implement RGB format validation
function isValidRgbColor(color) {
  // Use regex to validate format and range check via conversion
  const match = /^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)$/.test(color);
  if (!match) return false;
  
  try {
    rgbToHex(color); // This will throw if values are out of range
    return true;
  } catch (error) {
    return false;
  }
}

// Implement HSL format validation  
function isValidHslColor(color) {
  // Use regex to validate format and range check via conversion
  const match = /^hsl\(\s*\d{1,3}\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%\s*\)$/.test(color);
  if (!match) return false;
  
  try {
    hslToHex(color); // This will throw if values are out of range
    return true;
  } catch (error) {
    return false;
  }
}

// Implement named color validation
function isValidNamedColor(color) {
  // Use the same color list as namedColorToHex function
  try {
    namedColorToHex(color);
    return true;
  } catch (error) {
    return false;
  }
}

// Convert any supported color format to hex
function convertToHex(color, format) {
  switch (format) {
    case 'hex':
      return color.startsWith('#') ? color : `#${color}`;
    case 'rgb':
      return rgbToHex(color);
    case 'hsl':
      return hslToHex(color);
    case 'named':
      return namedColorToHex(color);
    default:
      throw new Error(`Unsupported color format: ${format}`);
  }
}

// Generate ReScript palette file content
function generatePaletteFile(primaryColor, paletteName = 'custom') {
  return `// Generated Color Palette
// Auto-generated by generate-palette CLI tool
// Do not edit this file manually

open ColorPalette

// Custom palette configuration
let ${paletteName}Palette = createPalette({
  baseColor: "${primaryColor}",
  name: "${paletteName}",
})

// TODO: Add secondary color generation
// let addSecondaryColor = (palette: generatedPalette, secondaryColor: string): generatedPalette => {
//   // Implementation needed
//   palette
// }

// TODO: Add tertiary color generation  
// let addTertiaryColor = (palette: generatedPalette, tertiaryColor: string): generatedPalette => {
//   // Implementation needed
//   palette
// }

// Export the generated palette for use in DesignSystem
let palette = ${paletteName}Palette
`;
}

// Main CLI function
async function generateColorPalette() {
  console.log('🎨 ReScript Color Palette Generator\n');

  try {
    const answers = await inquirer.prompt([
      {
        type: 'list',
        name: 'colorFormat',
        message: 'Color format:',
        choices: [
          { name: 'Hex (e.g., #ff6b35 or ff6b35)', value: 'hex' },
          { name: 'RGB (e.g., rgb(255, 107, 53))', value: 'rgb' },
          { name: 'HSL (e.g., hsl(14, 100%, 60%))', value: 'hsl' },
          { name: 'Named (e.g., red, blue, orange)', value: 'named' }
        ],
        default: 'hex'
      },
      {
        type: 'input',
        name: 'primaryColor',
        message: (answers) => {
          switch (answers.colorFormat) {
            case 'hex': return 'Primary color (hex):';
            case 'rgb': return 'Primary color (rgb):';
            case 'hsl': return 'Primary color (hsl):';
            case 'named': return 'Primary color (name):';
            default: return 'Primary color:';
          }
        },
        validate: (input, answers) => {
          if (!input.trim()) {
            return 'Please enter a color';
          }
          
          const format = answers.colorFormat;
          
          switch (format) {
            case 'hex':
              const color = input.startsWith('#') ? input : `#${input}`;
              if (!isValidHexColor(color)) {
                return 'Please enter a valid hex color (e.g., #3b82f6 or 3b82f6)';
              }
              return true;
              
            case 'rgb':
              if (!isValidRgbColor(input)) {
                return 'Please enter a valid RGB color (e.g., rgb(255, 107, 53))';
              }
              return true;
              
            case 'hsl':
              if (!isValidHslColor(input)) {
                return 'Please enter a valid HSL color (e.g., hsl(14, 100%, 60%))';
              }
              return true;
              
            case 'named':
              if (!isValidNamedColor(input)) {
                return 'Please enter a valid color name (e.g., red, blue, green)';
              }
              return true;
              
            default:
              return 'Invalid color format';
          }
        },
        filter: (input, answers) => {
          // Convert to hex format for consistent storage
          try {
            return convertToHex(input, answers.colorFormat);
          } catch (error) {
            return input; // Will be caught by validation
          }
        }
      },
      {
        type: 'input',
        name: 'paletteName',
        message: 'Palette name (optional):',
        default: 'custom',
        validate: (input) => {
          if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(input)) {
            return 'Palette name must be a valid ReScript identifier (letters and numbers, starting with letter)';
          }
          return true;
        }
      }
    ]);

    // Generate the ReScript file content
    const fileContent = generatePaletteFile(answers.primaryColor, answers.paletteName);
    
    // Write to src/core/GeneratedPalette.res
    const outputPath = path.join(__dirname, '..', 'src', 'core', 'GeneratedPalette.res');
    
    fs.writeFileSync(outputPath, fileContent);
    
    console.log(`\n✅ Generated palette file: ${outputPath}`);
    console.log(`🎨 Primary color: ${answers.primaryColor}`);
    console.log(`📝 Palette name: ${answers.paletteName}Palette`);
    console.log('\n💡 Next steps:');
    console.log('   1. Import GeneratedPalette in your DesignSystem.res');
    console.log('   2. Update defaultPalette to use your generated palette');
    console.log('   3. Run: npx rescript to compile');
    
  } catch (error) {
    if (error.isTtyError) {
      console.error('❌ Prompt couldn\'t be rendered in the current environment');
    } else {
      console.error('❌ Error:', error.message);
    }
    process.exit(1);
  }
}

// Run the CLI
generateColorPalette();