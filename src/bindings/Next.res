// Minimal Next.js bindings stub
module Link = {
  @react.component @module("next/link")
  external make: (~href: string, ~className: string=?, ~children: React.element) => React.element = "default"
}

module Router = {
  type router = {
    route: string,
    pathname: string,
    query: Js.Dict.t<string>,
  }
  
  @module("next/router") external useRouter: unit => router = "useRouter"
}

module Head = {
  @react.component @module("next/head")
  external make: (~children: React.element) => React.element = "default"
}

