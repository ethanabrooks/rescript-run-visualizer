@react.component
let make = (~client) => {
  let route = ReasonReactRouter.useUrl().hash->Routes.hashToRoute
  <div className="bg-white border-b border-gray-200">
    <div className="max-w-8xl mx-auto px-4 sm:px-6 lg:px-8">
      <Navigation route />
      {switch route {
      | Valid({granularity, ids, archived, where}) =>
        <div className={"flex flex-row"}>
          <Sidebar ids granularity archived where client /> // The sidebar lists each sweep or run
          <div
            className={"flex flex-grow flex-col max-h-screen overflow-y-scroll overscroll-contain"}>
            <div
              className={"flex flex-grow flex-col max-h-screen overflow-y-scroll overscroll-contain"}>
              <Display client granularity ids /> <ArchiveButton granularity ids /> // The charts display shows graphs and lists metadata per run
            </div>
          </div>
        </div>
      | NotFound(url) => <p> {React.string(`URL "${url}" not found`)} </p>
      | Redirect => <p> {React.string("Redirecting...")} </p>
      }}
    </div>
  </div>
}
