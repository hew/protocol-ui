// Minimal Playwright bindings stub  
type browser
type page
type elementHandle

module Browser = {
  type t = browser
  @send external newPage: t => promise<page> = "newPage"
  @send external close: t => promise<unit> = "close"
}

module Page = {
  type t = page
  @send external goto: (t, string) => promise<unit> = "goto"
  @send external url: t => string = "url"
  @send external title: t => promise<string> = "title"
  @send external locator: (t, string) => elementHandle = "locator"
  @send external waitForURL: (t, string) => promise<unit> = "waitForURL"
  @send external close: t => promise<unit> = "close"
}

module Browsers = {
  @module("playwright") external chromium: {..} = "chromium"
  @send external launch: {..} => promise<browser> = "launch"
}