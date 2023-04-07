import 'jquery'

import 'bootstrap/js/dist/modal'
import 'bootstrap/js/dist/tab'
import 'bootstrap/js/dist/alert'
import 'bootstrap/js/dist/scrollspy'
import 'bootstrap/js/dist/tooltip'
import 'bootstrap/js/dist/popover'

import 'jqcloud2/src/jqcloud'

import Chart from 'chart.js/auto'
import moveto from 'moveto/src/moveTo'

import './vendor/jquery.twbsPagination.js'
import './js/application.js'
import './js/chart.js'

window.MoveTo = moveto
window.Chart = Chart

window.bootstrap = require('bootstrap/dist/js/bootstrap.bundle.js')
