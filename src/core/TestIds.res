// STRICT: Compile-time verified test selectors
// When you delete a component, tests break at compile time
// NO magic strings allowed in tests

module Layout = {
  let container = "[data-testid='layout-container']"
  let navigation = "[data-testid='main-navigation']" 
}

module Navigation = {
  let logo = "[data-testid='logo-link']"
  let homeLink = "[data-testid='home-link']"
  let analyzeLink = "[data-testid='analyze-link']"
  let caseStudyLink = "[data-testid='case-study-link']"
}

module Analyze = {
  let heroHeading = "[data-testid='analyze-hero-heading']"
  let chatContainer = "[data-testid='salesforce-chat']"
  let demoButton = "[data-testid='demo-calculator-button']"
}

module CaseStudy = {
  let heroHeading = "[data-testid='case-study-hero-heading']"
  let savingsCard = "[data-testid='monthly-savings-card']"
  let roiCard = "[data-testid='roi-card']"
}

module Buttons = {
  let bookCallDesktop = "[data-testid='book-call-desktop']"
  let bookCallMobile = "[data-testid='book-call-mobile']"
  let primary = "[data-testid='primary-button']"
  let secondary = "[data-testid='secondary-button']"
}