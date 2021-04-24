import React from "react";
import { Vega } from "react-vega";


export function make(data, spec) {
    const [view, setView] = React.useState(null);
    const [initialData, setInitialData] = React.useState(null);
    React.useEffect(
        () => {
            if (initialData === null) {
                setInitialData(data);
            } else if (data.length && view != null) {
                const cs = view.changeset().insert(data[data.length - 1]);
                view.change("data", cs).run();
            }
        },
        [data, view]
    );
    return <Vega spec={spec} data={{ data }} onNewView={setView} />;

}