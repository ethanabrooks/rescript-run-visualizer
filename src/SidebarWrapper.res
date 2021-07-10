open Routes
open MetadataFilter
open Belt

type whereResults = Predicate.t<Belt.Result.t<Hasura.metadata, option<string>>>

let whereToTexts = (where: Hasura.where): Predicate.t<string> =>
  where->Predicate.map((Contains(json)) => json->Js.Json.stringify)

let whereOptionToTexts = (where: option<Hasura.where>): Predicate.t<string> =>
  where->Option.mapWithDefault(Predicate.Just(""), whereToTexts)

let rec resultsToWhere = (whereResults: whereResults): option<Hasura.where> =>
  switch whereResults {
  | And(a) => a->Array.keepMap(resultsToWhere)->And->Some
  | Or(a) => a->Array.keepMap(resultsToWhere)->Or->Some
  | Just(metadata) => metadata->Util.resultToOption->Option.map(x => x->Predicate.Just)
  }

let removeDummies = (texts: Predicate.t<string>) => {
  let f = a =>
    a->Array.keepMap(p =>
      switch p {
      | Predicate.Just("") => None
      | _ => p->Some
      }
    )
  switch texts {
  | Just(_) => texts
  | And(a) => a->f->And
  | Or(a) => a->f->Or
  }
}

let addDummies = (texts: Predicate.t<string>) =>
  switch texts {
  | Just(_) => texts
  | And(a) => [a->Array.concat([""->Just])->And, ""->Just]->Or
  | Or(a) => [a->Array.concat([""->Just])->Or, ""->Just]->And
  }

let buttonClass = "w-20 h-10 border border-gray-300 text-sm bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default px-2 items-center justify-center"

@react.component
let make = (
  ~ids: Set.Int.t,
  ~granularity,
  ~archived: bool,
  ~where: option<Hasura.where>,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let initialWhere = where
  let (whereTexts, setWhereTexts) = React.useState(_ => initialWhere->whereOptionToTexts)

  React.useEffect1(() => {
    setWhereTexts(_ => initialWhere->whereOptionToTexts)
    None
  }, [initialWhere])

  let whereResults = whereTexts->Predicate.map(textToResult)
  let where = whereResults->resultsToWhere
  let queryResult = SidebarItemsSubscription.useSidebarItems(
    ~granularity,
    ~archived,
    ~where,
    ~client,
  )

  let route = makeRoute(~granularity, ~ids, ~archived, ~where, ())
  let href = route->routeToHref

  let rec textsToComponents = (
    texts: Predicate.t<string>,
    addText: Predicate.t<string> => Predicate.t<string>,
  ): React.element => {
    let buttonClass = `${buttonClass} rounded-r-md`
    let elements = (array: array<Predicate.t<string>>, _and: bool) =>
      <div className="flex-col">
        <div> {"("->React.string} </div>
        <div className="flex">
          <div className="w-10" /> // indent
          <ul>
            {array
            ->Array.mapWithIndex((i, p) => {
              let addText = (pred: Predicate.t<string>): Predicate.t<string> => {
                let a = array->Util.setArray(i, pred)
                _and ? a->And : a->Or
              }
              p->textsToComponents(addText)
            })
            ->Array.zip(array)
            ->Array.mapWithIndex((i, (element, pred)) =>
              <div key={i->Int.toString}>
                <li>
                  {switch pred {
                  | Just(text) =>
                    let res = text->textToResult
                    <div className="flex items-center">
                      {element}
                      {_and
                        ? <button
                            type_="button"
                            onClick={_ =>
                              setWhereTexts(_ =>
                                array->Util.setArray(i, Or([pred, ""->Just]))->And
                              )}
                            disabled={res->Result.isError}
                            className={buttonClass}>
                            {"Or"->React.string}
                          </button>
                        : <button
                            type_="button"
                            onClick={_ =>
                              setWhereTexts(_ =>
                                array->Util.setArray(i, And([pred, ""->Just]))->Or
                              )}
                            disabled={res->Result.isError}
                            className={buttonClass}>
                            {"And"->React.string}
                          </button>}
                    </div>
                  | _ => element
                  }}
                </li>
                {i == array->Array.length - 1
                  ? <> </>
                  : <div className={"flex items-start"}>
                      <p className={filterTextClass}> {(_and ? "AND" : "OR")->React.string} </p>
                    </div>}
              </div>
            )
            ->React.array}
          </ul>
        </div>
        <div> {")"->React.string} </div>
      </div>

    switch texts {
    | Just(text) =>
      let setText = (text: string) => setWhereTexts(_ => text->Just->addText)
      <MetadataFilter text setText />
    | And(a) => a->elements(true)
    | Or(a) => a->elements(false)
    }
  }
  let table = switch granularity {
  | Run => "run"
  | Sweep => "sweep"
  }

  <div className="pb-10 resize-x w-1/3 m-5 max-h-screen overflow-y-scroll overscroll-contain">
    <div className="pb-5 -space-y-px">
      <label className={filterTextClass}>
        <a href> {`SELECT * FROM ${table} WHERE`->React.string} </a>
      </label>
      <ul className="list-inside">
        {switch Predicate.zip(whereTexts, whereResults) {
        | Just(text, res) =>
          let setText = text => setWhereTexts(_ => text->Just)
          let textArray: array<Predicate.t<string>> = [whereTexts]
          <div className="flex items-center pt-5">
            <MetadataFilter text setText />
            <button
              type_="button"
              onClick={_ => setWhereTexts(_ => textArray->And)}
              disabled={res->Result.isError}
              className={buttonClass}>
              {"And"->React.string}
            </button>
            <button
              type_="button"
              onClick={_ => setWhereTexts(_ => textArray->Or)}
              disabled={res->Result.isError}
              className={`${buttonClass} rounded-r-md`}>
              {"Or"->React.string}
            </button>
          </div>
        | _ => whereTexts->removeDummies->addDummies->textsToComponents(x => x)
        }}
      </ul>
    </div>
    {queryResult->Option.mapWithDefault(<p> {"Loading..."->React.string} </p>, queryResult =>
      switch queryResult {
      | Error(message) => <ErrorPage message />
      | Ok(items) => <Sidebar items ids />
      }
    )}
  </div>
}
