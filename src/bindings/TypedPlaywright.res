// Minimal TypedPlaywright bindings stub
include Playwright

type locator

module Locator = {
  type t = locator
  @send external click: t => promise<unit> = "click"
  @send external textContent: t => promise<option<string>> = "textContent"
}

// Simplified typed page interface
module TypedPage = {
  type layout = MainContent
  type homepage = MainHeading
  type navigation = HomeLink | ExamplesLink
  
  let waitForSelector = async (_page, ~layout as _=?, ~homepage as _=?, ()) => {
    // Simplified implementation - just wait a moment
    let _ = setTimeout(() => (), 100)
  }
  
  let getHomepageContent = async (page, _content) => {
    await Page.title(page)
  }
  
  let clickNavigation = async (page, _nav) => {
    await Page.goto(page, "/")
  }
  
  let isNavigationVisible = async (_page, _nav) => {
    true
  }
  
  let isLayoutVisible = async (_page, _layout) => {
    true
  }
}