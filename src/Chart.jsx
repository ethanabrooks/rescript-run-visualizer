import React from "react";
import { Vega } from "react-vega";


export function make(spec, newData) {
    const [view, setView] = React.useState(null);
    React.useEffect(
        () => {
            // From https://vega.github.io/vega/docs/api/view/#view_change
            // and https://colamda.de/blog/2020-12-03-React-Vega-Lifecycle/
            if (view != null) {
                var cs = null
                for (const d of newData) {
                    console.log(d)
                    cs = view.changeset().insert(d)
                }
                if (cs != null) {
                    view.change("data", cs).run();
                }
            }
        },
        [view, newData]
    );
    return <Vega spec={spec} onNewView={setView} />;

}