// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import {Socket} from "phoenix";
import NProgress from "nprogress";
import {LiveSocket} from "phoenix_live_view";

function update_options(el, options) {
    const children = new Array(...el.childNodes);

    const mk_opt = (rank, name) => {
        const tr = document.createElement('tr');

        const rank_td = document.createElement('td');
        const name_td = document.createElement('td');
        const drag_td = document.createElement('td');

        tr.appendChild(rank_td);
        tr.appendChild(name_td);
        tr.appendChild(drag_td);

        name_td.innerHTML = name;
        rank_td.innerHTML = rank;
        drag_td.innerHTML = '☰';

        name_td.className = 'opt-name';
        rank_td.className = 'opt-rank ta-center';
        drag_td.className = 'opt-drag ta-center';

        return tr;
    };

    const update_opt = (tr, rank, name) => {
        const rank_td = tr.getElementsByClassName('opt-rank')[0];
        const name_td = tr.getElementsByClassName('opt-name')[0];

        if (rank_td.innerHTML !== rank) rank_td.innerHTML = rank;
        if (name_td.innerHTML !== name) name_td.innerHTML = name;
    };

    options.forEach((option, idx) => {
        // modify
        if (children[idx]) {
            update_opt(children[idx], idx + 1, option);
        }
        // append
        else {
            el.appendChild(mk_opt(idx + 1, option));
        }
    });

    // delete
    children.slice(options.length).forEach(child => {
        el.removeChild(child);
    });
}

function report_option_select(socket, tbody, idx) {
    const children = new Array(...tbody.childNodes);
    const options = children.map(child => {
        const name_td = child.getElementsByClassName('opt-name')[0];
        return name_td.innerHTML;
    });
    socket.pushEvent("update_selection", {idx, options});
}

const Hooks = {
    FormReset: {
        mounted() {
            this.handleEvent("clear_add_option", ({form}) => {
                document.getElementById(form).reset();
            });
        },
    },
    DragTable: {
        mounted() {
            const inner = this.el.getElementsByTagName('tbody')[0];
            this.handleEvent(`options/${this.el.dataset.idx}/update`, msg => {
                update_options(inner, msg.options);
            });
            window.jquery_sortable(inner).sortable({
                handle: '.opt-drag',
                container: 'tbody',
                nodes: 'tr',
                nodes_type: 'tr',
                update: () => {
                    report_option_select(this, inner, this.el.dataset.idx);
                },
            });
        },
    },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    hooks: Hooks,
});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start());
window.addEventListener("phx:page-loading-stop", info => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

