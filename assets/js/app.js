import "phoenix_html";
import {Socket} from "phoenix";
import {LiveSocket} from "phoenix_live_view";
import {DragTable} from "./ranking_input.js";
import {AppendToItem} from "./append_box.js";
import topbar from "../vendor/topbar";
import Sortable from "../vendor/draganddrop.js";
import jQuery from "../vendor/jquery.js";

const Hooks = {
    DragTable,
    AppendToItem,
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    hooks: Hooks,
});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;


if (typeof define !== 'undefined') {
    define(['jquery'], Sortable);
} else {
    Sortable(jQuery, Sortable);
}
window.jquery_sortable = Sortable;
