const libVoyager = require('voyager');

export function make(data) {
    const container = document.getElementById("voyager-embed");
    const config = undefined;
    const voyagerInstance = libVoyager.CreateVoyager(container, config, data)
    return <div>"hello"</div>
}