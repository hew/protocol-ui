// Tailwind CSS Type Definitions
// Low-level Tailwind class mappings

// Font size scale (polymorphic variants for consistency)
type fontSize = [
  | #XS    // text-xs (12px)
  | #SM    // text-sm (14px)
  | #Base  // text-base (16px)
  | #LG    // text-lg (18px)
  | #XL    // text-xl (20px)
  | #XL2   // text-2xl (24px)
  | #XL3   // text-3xl (30px)
  | #XL4   // text-4xl (36px)
  | #XL5   // text-5xl (48px)
  | #XL6   // text-6xl (60px)
]

// Font Weight Scale - Maps to Tailwind font-weight classes
type fontWeight = [
  | #Thin        // font-thin (100)
  | #ExtraLight  // font-extralight (200)
  | #Light       // font-light (300)
  | #Normal      // font-normal (400)
  | #Medium      // font-medium (500)
  | #SemiBold    // font-semibold (600)
  | #Bold        // font-bold (700)
  | #ExtraBold   // font-extrabold (800)
  | #Black       // font-black (900)
]

// Spacing Scale - Maps to Tailwind spacing classes (rem values)
type spacing = [
  | #0   // 0
  | #1   // 0.25rem (4px)
  | #2   // 0.5rem (8px)
  | #3   // 0.75rem (12px)
  | #4   // 1rem (16px)
  | #5   // 1.25rem (20px)
  | #6   // 1.5rem (24px)
  | #8   // 2rem (32px)
  | #10  // 2.5rem (40px)
  | #12  // 3rem (48px)
  | #16  // 4rem (64px)
  | #20  // 5rem (80px)
  | #24  // 6rem (96px)
  | #32  // 8rem (128px)
  | #40  // 10rem (160px)
  | #48  // 12rem (192px)
  | #64  // 16rem (256px)
]


// Conversion functions - Type-safe mapping to Tailwind classes
let fontSizeToClass = (size: fontSize): string => switch size {
  | #XS => "text-xs"
  | #SM => "text-sm"
  | #Base => "text-base"
  | #LG => "text-lg"
  | #XL => "text-xl"
  | #XL2 => "text-2xl"
  | #XL3 => "text-3xl"
  | #XL4 => "text-4xl"
  | #XL5 => "text-5xl"
  | #XL6 => "text-6xl"
}

let fontWeightToClass = (weight: fontWeight): string => switch weight {
  | #Thin => "font-thin"
  | #ExtraLight => "font-extralight"
  | #Light => "font-light"
  | #Normal => "font-normal"
  | #Medium => "font-medium"
  | #SemiBold => "font-semibold"
  | #Bold => "font-bold"
  | #ExtraBold => "font-extrabold"
  | #Black => "font-black"
}

let spacingToClass = (space: spacing, property: [#p | #px | #py | #pt | #pb | #pl | #pr | #m | #mx | #my | #mt | #mb | #ml | #mr]): string => {
  let sizeValue = switch space {
  | #0 => "0"
  | #1 => "1"
  | #2 => "2"
  | #3 => "3"
  | #4 => "4"
  | #5 => "5"
  | #6 => "6"
  | #8 => "8"
  | #10 => "10"
  | #12 => "12"
  | #16 => "16"
  | #20 => "20"
  | #24 => "24"
  | #32 => "32"
  | #40 => "40"
  | #48 => "48"
  | #64 => "64"
  }
  
  let prefix = switch property {
  | #p => "p-"
  | #px => "px-"
  | #py => "py-"
  | #pt => "pt-"
  | #pb => "pb-"
  | #pl => "pl-"
  | #pr => "pr-"
  | #m => "m-"
  | #mx => "mx-"
  | #my => "my-"
  | #mt => "mt-"
  | #mb => "mb-"
  | #ml => "ml-"
  | #mr => "mr-"
  }
  
  prefix ++ sizeValue
}

// Text Alignment
type textAlign = [
  | #Left
  | #Center
  | #Right
  | #Justify
]

// Line Height Scale
type lineHeight = [
  | #Tight    // leading-tight
  | #Normal   // leading-normal  
  | #Relaxed  // leading-relaxed
  | #Loose    // leading-loose
]

let textAlignToClass = (align: textAlign): string => switch align {
| #Left => "text-left"
| #Center => "text-center"
| #Right => "text-right"
| #Justify => "text-justify"
}

let lineHeightToClass = (height: lineHeight): string => switch height {
| #Tight => "leading-tight"
| #Normal => "leading-normal"
| #Relaxed => "leading-relaxed"
| #Loose => "leading-loose"
}