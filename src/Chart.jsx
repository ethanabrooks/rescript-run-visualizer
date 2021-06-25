import React from "react";
import { Vega } from "react-vega";


export function make(data, newData, spec) {
    const [view, setView] = React.useState(null);
    React.useEffect(
        () => {
            if (view != null) {
                var cs = null
                for (const d of newData) {
                    cs = view.changeset().insert(d)
                }
                if (cs != null) {
                    view.change("data", cs).run();
                }
            }
        },
        [newData, view]
    );
    return <Vega spec={spec} data={{ data }} onNewView={setView} />;

}