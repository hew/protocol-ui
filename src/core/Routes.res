// STRICT: Type-safe routing - no hardcoded URL strings allowed
// Benefits: Routes are compile-time verified, impossible to have broken links

type pageId = 
  | Home
  | CaseStudy
  | Analyze
  | About

type route = {
  id: pageId,
  path: string,
  title: string,
  description: string,
}

// Single source of truth for all routes
let routes = [
  {
    id: Home,
    path: "/",
    title: "SalesEscape - Escape Salesforce costs with AI automation",
    description: "Replace expensive Salesforce with AI-first revenue operations. Cut costs by 80% while increasing efficiency.",
  },
  {
    id: CaseStudy,
    path: "/case-study",
    title: "Case Study: 80% Cost Reduction - SalesEscape",
    description: "50-person sales team replaces Salesforce with AI-first revenue operations and saves $12.3k monthly.",
  },
  {
    id: Analyze,
    path: "/analyze",
    title: "Salesforce Cost Calculator - SalesEscape",
    description: "AI analyzes your Salesforce setup and finds optimization opportunities. Get instant cost savings estimates.",
  },
  {
    id: About,
    path: "/about",
    title: "About - Ex-Salesforce Developer - SalesEscape",
    description: "Built by an ex-Salesforce developer who escaped the ecosystem and helps others do the same.",
  },
]

// Type-safe route operations
let getRoute = (pageId: pageId): route => {
  routes
  ->Array.find(r => r.id === pageId)
  ->Option.getOr({
    id: Home,
    path: "/",
    title: "SalesEscape",
    description: "Escape Salesforce costs",
  })
}

let getPath = (pageId: pageId): string => getRoute(pageId).path
let getTitle = (pageId: pageId): string => getRoute(pageId).title
let getDescription = (pageId: pageId): string => getRoute(pageId).description

// Enhanced Link component that only accepts valid routes
module SafeLink = {
  @react.component
  let make = (~to: pageId, ~className: string="", ~children: React.element) => {
    let path = getPath(to)
    <Next.Link href={path} className>
      {children}
    </Next.Link>
  }
}