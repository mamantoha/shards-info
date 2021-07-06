import "jquery";

import "bootstrap/js/dist/modal";
import "bootstrap/js/dist/tab";
import "bootstrap/js/dist/collapse";
import "bootstrap/js/dist/dropdown";
import "bootstrap/js/dist/alert";

import Turbolinks from "turbolinks";

import "jqcloud2/src/jqcloud";

import moveto from "moveto/src/moveTo";
window.MoveTo = moveto;

import "./js/jquery.twbsPagination.js";
import "./js/application.js";

Turbolinks.start();
