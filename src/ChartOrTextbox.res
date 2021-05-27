open EditSpec
type specState =
  | InCharts(Js.Json.t)
  | NotInCharts(Js.Json.t => unit)

type state =
  | Rendering(Js.Json.t)
  | Editing

@react.component
let make = (~data: list<Js.Json.t>, ~specState) => {
  let (state, setState) = React.useState(_ =>
    switch specState {
    | InCharts(spec) => Rendering(spec)
    | _ => Editing
    }
  )

  switch state {
  | Rendering(spec) => <ChartAndButtons data spec edit={spec => setState(_ => Editing)} />
  | Editing =>
    <EditSpec
      action={switch specState {
      | InCharts(spec) =>
        RevertToOriginalSpec({spec: spec, callback: _ => setState(_ => Rendering(spec))})
      | NotInCharts(addToCharts) => AddSpecToCharts(addToCharts)
      }}
      visualize={spec => setState(_ => Rendering(spec))}
    />
  }
}
