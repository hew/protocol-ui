// Node.js bindings for CLI functionality

// Commander.js bindings
type command

@module("commander") @new
external createCommand: unit => command = "Command"

@send
external argument: (command, string, string) => command = "argument"

@send
external description: (command, string) => command = "description"

@send
external action: (command, 'a => unit) => command = "action"

@send
external addCommand: (command, command) => command = "addCommand"

@send
external name: (command, string) => command = "name"

@send
external option: (command, string, string, string) => command = "option"

@send
external version: (command, string) => command = "version"

@send
external parse: command => unit = "parse"

// Fetch API bindings for HTTP requests
@val
external fetch: string => Promise.t<'response> = "fetch"

type response = {
  ok: bool,
  status: int,
}

@send
external json: 'response => Promise.t<'a> = "json"

@send
external text: 'response => Promise.t<string> = "text"

// URL parsing
@new
external createUrl: string => {..} = "URL"

// Process and console
@val
external processArgv: array<string> = "process.argv"

@val
external consoleLog: 'a => unit = "console.log"

@val
external consoleError: 'a => unit = "console.error"

// File system bindings
@module("fs")
external writeFileSync: (string, string) => unit = "writeFileSync"

// Chalk bindings - importing default export
@module("chalk") @scope("default")
external chalkGreen: string => string = "green"

@module("chalk") @scope("default")
external chalkRed: string => string = "red"

@module("chalk") @scope("default")
external chalkBlue: string => string = "blue"

@module("chalk") @scope("default")
external chalkYellow: string => string = "yellow"

// Chalk default export as object with color functions
type chalkObj = {
  red: string => string,
  yellow: string => string,
  green: string => string,
  blue: string => string,
}

@module("chalk")
external chalk: chalkObj = "default"

// File system bindings
@module("fs")
external readFileSync: string => string = "readFileSync"

@module("fs")
external existsSync: string => bool = "existsSync"

@module("fs")
external readdirSync: string => array<string> = "readdirSync"
