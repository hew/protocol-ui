// Type-safe selector system for components
// This ensures selectors match actual component markup

module Navigation = {
  type t = 
    | Logo
    | HomeLink 
    | ExamplesLink
    | GithubLink
    | NavContainer
    
  let toString = (selector: t): string => {
    switch selector {
    | Logo => "nav img"
    | HomeLink => "a[href='/']"
    | ExamplesLink => "a[href='/examples']" 
    | GithubLink => "a[target='_blank']"
    | NavContainer => "nav"
    }
  }
}

module MainLayout = {
  type t =
    | MainContent
    | Container
    | Navigation
    | LayoutContainer
    
  let toString = (selector: t): string => {
    switch selector {
    | MainContent => "main"
    | Container => "[data-testid='main-content-container']"
    | Navigation => "nav"
    | LayoutContainer => "[data-testid='layout-container']"
    }
  }
}

module Homepage = {
  type t =
    | MainHeading
    | SubHeading
    | CodeBlock
    | Paragraph
    
  let toString = (selector: t): string => {
    switch selector {
    | MainHeading => "h1"
    | SubHeading => "h2"
    | CodeBlock => "pre"
    | Paragraph => "p"
    }
  }
}

module Examples = {
  type t =
    | Title
    | ExamplesList
    | ExampleItem
    
  let toString = (selector: t): string => {
    switch selector {
    | Title => "h1"
    | ExamplesList => "ul"
    | ExampleItem => "li"
    }
  }
}

module DevPlayground = {
  type t =
    | PlaygroundTitle
    | SectionNav
    | SectionButton(string)
    | ContentArea
    | ButtonShowcase
    | ModalShowcase
    | DropdownShowcase
    | ToggleShowcase
    | ThemeShowcase
    
  let toString = (selector: t): string => {
    switch selector {
    | PlaygroundTitle => "h1"
    | SectionNav => "nav"
    | SectionButton(section) => `button:has-text("${section}")`
    | ContentArea => "main"
    | ButtonShowcase => "[data-testid='button-showcase']"
    | ModalShowcase => "[data-testid='modal-showcase']"
    | DropdownShowcase => "[data-testid='dropdown-showcase']"
    | ToggleShowcase => "[data-testid='toggle-showcase']" 
    | ThemeShowcase => "[data-testid='theme-showcase']"
    }
  }
}

module Button = {
  type t =
    | Primary
    | Secondary
    | Success
    | Error
    | Warning
    | Ghost
    | Disabled
    | Loading
    | BookACallDesktop
    | BookACallMobile
    
  let toString = (selector: t): string => {
    switch selector {
    | Primary => "button:has-text('Primary')"
    | Secondary => "button:has-text('Secondary')"
    | Success => "button:has-text('Success')"
    | Error => "button:has-text('Error')"
    | Warning => "button:has-text('Warning')"
    | Ghost => "button:has-text('Ghost')"
    | Disabled => "button:disabled"
    | Loading => "button:has([class*='animate-spin'])"
    | BookACallDesktop => "[data-testid='book-a-call-button-desktop']"
    | BookACallMobile => "[data-testid='book-a-call-button-mobile']"
    }
  }
}

module Modal = {
  type t =
    | Dialog
    | Title
    | Description
    | CloseButton
    | ConfirmButton
    | CancelButton
    
  let toString = (selector: t): string => {
    switch selector {
    | Dialog => "[role='dialog']"
    | Title => "[role='dialog'] h2"
    | Description => "[role='dialog'] p"
    | CloseButton => "button:has-text('Cancel')"
    | ConfirmButton => "button:has-text('Save'), button:has-text('Confirm'), button:has-text('Delete')"
    | CancelButton => "button:has-text('Cancel')"
    }
  }
}

module Link = {
  type t =
    | Logo
    | Home
    | Analyze
    | CaseStudy

  let toString = (selector: t): string => {
    switch selector {
    | Logo => "[data-testid='logo-link']"
    | Home => "[data-testid='home-link']"
    | Analyze => "[data-testid='analyze-link']"
    | CaseStudy => "[data-testid='case-study-link']"
    }
  }
}

module Dropdown = {
  type t =
    | MenuButton
    | MenuItems
    | MenuItem(string)
    | UserMenu
    | ActionMenu
    
  let toString = (selector: t): string => {
    switch selector {
    | MenuButton => "[role='button']"
    | MenuItems => "[role='menu']"
    | MenuItem(text) => `[role='menuitem']:has-text("${text}")`
    | UserMenu => "[data-testid='user-menu']"
    | ActionMenu => "[data-testid='action-menu']"
    }
  }
}

module Toggle = {
  type t =
    | Switch
    | Label
    | Description
    | SettingToggle
    
  let toString = (selector: t): string => {
    switch selector {
    | Switch => "[role='switch']"
    | Label => "label"
    | Description => "label + p"
    | SettingToggle => "[data-testid='setting-toggle']"
    }
  }
}