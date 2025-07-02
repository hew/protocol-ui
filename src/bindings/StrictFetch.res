// STRICT: Type-safe fetch bindings - no generic types
// Benefits: Compile-time verification of request/response structure

module Method = {
  type t = [#GET | #POST | #PUT | #DELETE]
  
  let toString = (method: t): string => {
    switch method {
    | #GET => "GET"
    | #POST => "POST" 
    | #PUT => "PUT"
    | #DELETE => "DELETE"
    }
  }
}

module Headers = {
  type t = Js.Dict.t<string>
  
  let json = (): t => {
    let headers = Js.Dict.empty()
    Js.Dict.set(headers, "Content-Type", "application/json")
    headers
  }
  
  let withAuth = (token: string): t => {
    let headers = json()
    Js.Dict.set(headers, "Authorization", `Bearer ${token}`)
    headers
  }
}

module RequestInit = {
  type t = {
    method: Method.t,
    headers: Headers.t,
    body: string,
  }
  
  let make = (~method: Method.t, ~headers: Headers.t, ~body: string="") => {
    {method, headers, body}
  }
  
  let get = () => make(~method=#GET, ~headers=Headers.json())
  
  let post = (~body: string) => 
    make(~method=#POST, ~headers=Headers.json(), ~body)
}

module Response = {
  type t
  
  @get external ok: t => bool = "ok"
  @get external status: t => int = "status" 
  @get external statusText: t => string = "statusText"
  @send external json: t => promise<Js.Json.t> = "json"
  @send external text: t => promise<string> = "text"
}

@val external fetch: (string, RequestInit.t) => promise<Response.t> = "fetch"

// Higher-level API wrappers
module Api = {
  let get = async (url: string): result<Js.Json.t, string> => {
    try {
      let response = await fetch(url, RequestInit.get())
      if Response.ok(response) {
        let data = await Response.json(response)
        Ok(data)
      } else {
        Error(`HTTP ${Response.status(response)->Int.toString}: ${Response.statusText(response)}`)
      }
    } catch {
    | _ => Error("Network error")
    }
  }
  
  let post = async (url: string, body: Js.Json.t): result<Js.Json.t, string> => {
    try {
      let bodyString = Js.Json.stringify(body)
      let response = await fetch(url, RequestInit.post(~body=bodyString))
      if Response.ok(response) {
        let data = await Response.json(response)
        Ok(data)
      } else {
        Error(`HTTP ${Response.status(response)->Int.toString}: ${Response.statusText(response)}`)
      }
    } catch {
    | _ => Error("Network error")
    }
  }
}