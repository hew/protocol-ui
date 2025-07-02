// STRICT: Centralized configuration - no magic URLs or constants
// Benefits: Change URL once, updates everywhere. Compile-time verification.

module Urls = {
  let baseUrl = "https://your-site.com" // Update this for your site
  let github = "https://github.com/your-username/your-repo" // Update this for your repo
  
  // Derived URLs - maintained automatically
  let logo = `${baseUrl}/logo.svg`
  let ogImage = `${baseUrl}/og-image.svg`
  let appleTouchIcon = `${baseUrl}/apple-touch-icon.svg`
  let favicon = `${baseUrl}/favicon.svg`
}

module Api = {
  let health = "/api/health"
  // Add your API endpoints here
}

module Timing = {
  // API timeouts
  let apiTimeout = 30000
  let shortTimeout = 10000
  
  // UI interaction delays
  let scrollDelay = 100
  let typingDelay = 200
}

module Animation = {
  type duration = Fast | Medium | Slow
  
  let durationToMs = (duration: duration): int => {
    switch duration {
    | Fast => 150
    | Medium => 300
    | Slow => 500
    }
  }
  
  let durationToDelay = (duration: duration): string => {
    switch duration {
    | Fast => "0.15s"
    | Medium => "0.3s" 
    | Slow => "0.5s"
    }
  }
  
  // Pre-defined animation delays for consistency
  let delay0 = "0s"
  let delay200 = "0.2s"
  let delay400 = "0.4s"
}

module Layout = {
  // Consistent container max-widths
  let maxWidthSm = "max-w-2xl"
  let maxWidthMd = "max-w-4xl"
  let maxWidthLg = "max-w-6xl"
  let maxWidthXl = "max-w-7xl"
  
  // Standard content width (used throughout site)
  let contentWidth = maxWidthMd
}