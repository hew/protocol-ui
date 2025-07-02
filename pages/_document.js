import { Html, Head, Main, NextScript } from 'next/document'

export default function Document() {
  return (
    <Html lang="en">
      <Head>
        {/* Primary Meta Tags */}
        <meta name="title" content="SalesEscape - Escape Salesforce Costs" />
        <meta name="description" content="Ex-Salesforce developer helps you escape overpriced CRM systems with AI-first automation. Save 80% on costs with proven migration strategies." />
        
        {/* Open Graph / Facebook */}
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://salesescape.co/" />
        <meta property="og:title" content="SalesEscape - Escape Salesforce Costs" />
        <meta property="og:description" content="Ex-Salesforce developer helps you escape overpriced CRM systems with AI-first automation. Save 80% on costs with proven migration strategies." />
        <meta property="og:image" content="https://salesescape.co/og-image.svg" />
        
        {/* Twitter */}
        <meta property="twitter:card" content="summary_large_image" />
        <meta property="twitter:url" content="https://salesescape.co/" />
        <meta property="twitter:title" content="SalesEscape - Escape Salesforce Costs" />
        <meta property="twitter:description" content="Ex-Salesforce developer helps you escape overpriced CRM systems with AI-first automation. Save 80% on costs with proven migration strategies." />
        <meta property="twitter:image" content="https://salesescape.co/og-image.svg" />
        
        {/* Favicon */}
        <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.svg" />
        
        {/* Manifest */}
        <link rel="manifest" href="/manifest.json" />
        
        {/* Theme */}
        <meta name="theme-color" content="#000000" />
      </Head>
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}