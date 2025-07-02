// Minimal HeadlessUI bindings stub
module Menu = {
  module Button = {
    @react.component @module("@headlessui/react")
    external make: (~className: string=?, ~children: React.element) => React.element = "Menu.Button"
  }
  
  module Items = {
    @react.component @module("@headlessui/react")  
    external make: (~className: string=?, ~children: React.element) => React.element = "Menu.Items"
  }
  
  module Item = {
    type renderProps = {active: bool, disabled: bool}
    @react.component @module("@headlessui/react")
    external make: (~disabled: bool=?, ~className: string=?, ~children: renderProps => React.element) => React.element = "Menu.Item"
  }

  @react.component @module("@headlessui/react")
  external make: (~className: string=?, ~children: React.element) => React.element = "Menu"
}

module Dialog = {
  @react.component @module("@headlessui/react")
  external make: (~\"open": bool, ~onClose: unit => unit, ~className: string=?, ~children: React.element) => React.element = "Dialog"
  
  module Panel = {
    @react.component @module("@headlessui/react")
    external make: (~className: string=?, ~children: React.element) => React.element = "Dialog.Panel"
  }
  
  module Title = {
    @react.component @module("@headlessui/react")
    external make: (~className: string=?, ~children: React.element) => React.element = "Dialog.Title"
  }
  
  module Description = {
    @react.component @module("@headlessui/react")
    external make: (~className: string=?, ~children: React.element) => React.element = "Dialog.Description"
  }
}

module Switch = {
  @react.component @module("@headlessui/react")
  external make: (~checked: bool, ~onChange: bool => unit, ~className: string=?, ~children: React.element=?) => React.element = "Switch"
}