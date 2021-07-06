import React from "react";
import { Vega } from "react-vega";


export function make(initialData, data, spec) {
    const [view, setView] = React.useState(null);
    React.useEffect(
        () => {
            if (view != null) {
                var cs = null
                for (const d of data) {
                    cs = view.changeset().insert(d)
                }
                if (cs != null) {
                    view.change("data", cs).run();
                }
            }
        },
        [data, view]
    );
    return <Vega spec={spec} data={{ initialData }} onNewView={setView} />;

}