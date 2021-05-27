open SpecEditor
open Belt

type submit = Js.Json.t => unit

type specState =
  | Spec({spec: Js.Json.t, submit: submit})
  | NoSpec({submit: submit})

type state =
  | Rendering(Js.Json.t)
  | Editing

@react.component
let make = (~data: array<Js.Json.t>, ~specState) => {
  let (state, setState) = React.useState(_ =>
    switch specState {
    | Spec({spec}) => Rendering(spec)
    | NoSpec(_) => Editing
    }
  )

  switch state {
  | Rendering(spec) => <ChartAndButtons data spec edit={spec => setState(_ => Editing)} />
  | Editing => {
      let (initialText, buttons) = switch specState {
      | Spec({spec, submit}) => {
          let initialText = spec->Js.Json.stringifyWithSpace(2)
          let buttons = [
            {
              text: "Submit",
              callback: spec =>
                spec->Result.mapWithDefault((), spec => {
                  spec->submit
                  setState(_ => Rendering(spec))
                }),
              disabled: Result.isError,
            },
            {text: "Cancel", callback: _ => setState(_ => Rendering(spec)), disabled: _ => false},
          ]
          (initialText, buttons)
        }
      | NoSpec({submit}) => {
          let initialText = "{}"
          let buttons = [
            {
              text: "Submit",
              callback: spec =>
                spec->Result.mapWithDefault((), spec => {
                  setState(_ => Rendering(spec))
                  spec->submit
                }),
              disabled: Result.isError,
            },
          ]
          (initialText, buttons)
        }
      }
      <SpecEditor initialText buttons />
    }
  }
}
