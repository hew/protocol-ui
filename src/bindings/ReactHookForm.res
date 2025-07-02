// ReScript bindings for React Hook Form

type fieldError = {
  message: option<string>,
  @as("type") type_: option<string>,
}

type formState = {
  errors: Js.Dict.t<fieldError>,
  isSubmitting: bool,
  isValid: bool,
}

type registerOptions = {
  required: option<bool>,
  pattern: option<Js.Re.t>,
  minLength: option<int>,
  maxLength: option<int>,
  validate: option<string => bool>,
}

type registerReturn = {
  name: string,
  onChange: ReactEvent.Form.t => unit,
  onBlur: ReactEvent.Focus.t => unit,
  ref: ReactDOM.Ref.t,
}

type useFormReturn<'data> = {
  register: (string, ~options: registerOptions=?) => registerReturn,
  handleSubmit: ('data => unit) => ReactEvent.Form.t => unit,
  formState: formState,
  reset: unit => unit,
  setValue: (string, string) => unit,
  getValues: unit => 'data,
}

@module("react-hook-form")
external useForm: unit => useFormReturn<'data> = "useForm"