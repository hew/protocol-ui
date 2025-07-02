// Unified Style Props System
// Central record type for all styling props that components may accept
// Eliminates duplication and ensures consistency across components

open TailwindTypes

// Core style properties record - single source of truth
type styleProps = {
  // Typography
  size: option<fontSize>,
  weight: option<fontWeight>,
  align: option<textAlign>,
  lineHeight: option<lineHeight>,
  
  // Spacing (margin)
  mt: option<spacing>,
  mb: option<spacing>,
  ml: option<spacing>,
  mr: option<spacing>,
  mx: option<spacing>,
  my: option<spacing>,
  m: option<spacing>,
  
  // Spacing (padding)
  pt: option<spacing>,
  pb: option<spacing>,
  pl: option<spacing>,
  pr: option<spacing>,
  px: option<spacing>,
  py: option<spacing>,
  p: option<spacing>,
}

// Default empty style props
let empty: styleProps = {
  size: None,
  weight: None,
  align: None,
  lineHeight: None,
  mt: None,
  mb: None,
  ml: None,
  mr: None,
  mx: None,
  my: None,
  m: None,
  pt: None,
  pb: None,
  pl: None,
  pr: None,
  px: None,
  py: None,
  p: None,
}

// Helper converters - delegate to existing TailwindTypes utilities
let sizeToClass = TailwindTypes.fontSizeToClass
let weightToClass = TailwindTypes.fontWeightToClass
let alignToClass = TailwindTypes.textAlignToClass
let lineHeightToClass = TailwindTypes.lineHeightToClass
let spacingToClass = TailwindTypes.spacingToClass

// Convert style props to CSS class array
let toClasses = (props: styleProps): array<string> => {
  let classes = []
  
  // Typography classes
  let classes = switch props.size {
  | Some(size) => Array.concat(classes, [sizeToClass(size)])
  | None => classes
  }
  
  let classes = switch props.weight {
  | Some(weight) => Array.concat(classes, [weightToClass(weight)])
  | None => classes
  }
  
  let classes = switch props.align {
  | Some(align) => Array.concat(classes, [alignToClass(align)])
  | None => classes
  }
  
  let classes = switch props.lineHeight {
  | Some(lineHeight) => Array.concat(classes, [lineHeightToClass(lineHeight)])
  | None => classes
  }
  
  // Margin classes
  let classes = switch props.mt {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #mt)])
  | None => classes
  }
  
  let classes = switch props.mb {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #mb)])
  | None => classes
  }
  
  let classes = switch props.ml {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #ml)])
  | None => classes
  }
  
  let classes = switch props.mr {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #mr)])
  | None => classes
  }
  
  let classes = switch props.mx {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #mx)])
  | None => classes
  }
  
  let classes = switch props.my {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #my)])
  | None => classes
  }
  
  let classes = switch props.m {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #m)])
  | None => classes
  }
  
  // Padding classes
  let classes = switch props.pt {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #pt)])
  | None => classes
  }
  
  let classes = switch props.pb {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #pb)])
  | None => classes
  }
  
  let classes = switch props.pl {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #pl)])
  | None => classes
  }
  
  let classes = switch props.pr {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #pr)])
  | None => classes
  }
  
  let classes = switch props.px {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #px)])
  | None => classes
  }
  
  let classes = switch props.py {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #py)])
  | None => classes
  }
  
  let classes = switch props.p {
  | Some(spacing) => Array.concat(classes, [spacingToClass(spacing, #p)])
  | None => classes
  }
  
  classes->Array.filter(cls => cls !== "")
}

// Utility to combine multiple style props (later props override earlier ones)
let merge = (props1: styleProps, props2: styleProps): styleProps => {
  {
    size: props2.size->Option.isSome ? props2.size : props1.size,
    weight: props2.weight->Option.isSome ? props2.weight : props1.weight,
    align: props2.align->Option.isSome ? props2.align : props1.align,
    lineHeight: props2.lineHeight->Option.isSome ? props2.lineHeight : props1.lineHeight,
    mt: props2.mt->Option.isSome ? props2.mt : props1.mt,
    mb: props2.mb->Option.isSome ? props2.mb : props1.mb,
    ml: props2.ml->Option.isSome ? props2.ml : props1.ml,
    mr: props2.mr->Option.isSome ? props2.mr : props1.mr,
    mx: props2.mx->Option.isSome ? props2.mx : props1.mx,
    my: props2.my->Option.isSome ? props2.my : props1.my,
    m: props2.m->Option.isSome ? props2.m : props1.m,
    pt: props2.pt->Option.isSome ? props2.pt : props1.pt,
    pb: props2.pb->Option.isSome ? props2.pb : props1.pb,
    pl: props2.pl->Option.isSome ? props2.pl : props1.pl,
    pr: props2.pr->Option.isSome ? props2.pr : props1.pr,
    px: props2.px->Option.isSome ? props2.px : props1.px,
    py: props2.py->Option.isSome ? props2.py : props1.py,
    p: props2.p->Option.isSome ? props2.p : props1.p,
  }
}

// Convenience functions for creating common style prop patterns
module Shortcuts = {
  let mt = (spacing) => {...empty, mt: Some(spacing)}
  let mb = (spacing) => {...empty, mb: Some(spacing)}
  let ml = (spacing) => {...empty, ml: Some(spacing)}
  let mr = (spacing) => {...empty, mr: Some(spacing)}
  let mx = (spacing) => {...empty, mx: Some(spacing)}
  let my = (spacing) => {...empty, my: Some(spacing)}
  let m = (spacing) => {...empty, m: Some(spacing)}
  
  let pt = (spacing) => {...empty, pt: Some(spacing)}
  let pb = (spacing) => {...empty, pb: Some(spacing)}
  let pl = (spacing) => {...empty, pl: Some(spacing)}
  let pr = (spacing) => {...empty, pr: Some(spacing)}
  let px = (spacing) => {...empty, px: Some(spacing)}
  let py = (spacing) => {...empty, py: Some(spacing)}
  let p = (spacing) => {...empty, p: Some(spacing)}
  
  let size = (fontSize) => {...empty, size: Some(fontSize)}
  let weight = (fontWeight) => {...empty, weight: Some(fontWeight)}
  let align = (textAlign) => {...empty, align: Some(textAlign)}
  let lineHeight = (lineHeight) => {...empty, lineHeight: Some(lineHeight)}
}