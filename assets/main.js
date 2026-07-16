import $ from "jquery";
import * as bootstrap from "bootstrap";

import "./main.scss";
import "./js/word-cloud.js";

import Chart from "chart.js/auto";
import moveto from "moveto/src/moveTo";

window.$ = $;
window.jQuery = $;
window.MoveTo = moveto;
window.Chart = Chart;
window.bootstrap = bootstrap;

import("./vendor/jquery.twbsPagination.js").then(() => {
  import("./js/application.js");
  import("./js/chart.js");
});
