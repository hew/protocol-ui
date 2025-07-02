// Protocol UI - Systematic AI Component Generation
// Clean, minimal homepage following Dieter Rams principles

// AI-generated components
module AppText = AppText
module AppButton = AppButton
module DS = DesignSystem

@react.component
let make = () => {
  <ThemeContext.ThemeProvider>
    <MainLayout>
      <div className="min-h-screen flex items-center justify-center px-6">
        <div className="max-w-2xl text-center space-y-12">
          
          // Main heading - Protocol UI
          <div className="space-y-4">
            <AppText tag=#h1 color=Primary size=#xl4>
              {"Protocol UI"->React.string}
            </AppText>
            <AppText tag=#h2 color=Secondary>
              {"Systematic protocols for AI-powered ReScript component generation"->React.string}
            </AppText>
          </div>
          
          // Key principle - minimal but meaningful
          <div className="max-w-xl mx-auto">
            <AppText tag=#p color=Tertiary>
              {"DSPy-inspired architecture. Type-safe validation. Design system integration. Components that follow Dieter Rams' principles by design."->React.string}
            </AppText>
          </div>
          
          // Simple, purposeful actions
          <div className="flex gap-6 justify-center">
            <AppButton 
              variant=#primary
              onClick={_ => {
                let _ = %raw(`window.open('https://github.com/hew/protocol-ui', '_blank')`)
              }}>
              {"View on GitHub"->React.string}
            </AppButton>
          </div>
          
        </div>
      </div>
    </MainLayout>
  </ThemeContext.ThemeProvider>
}