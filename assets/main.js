import 'bootstrap/js/dist/util'
import 'bootstrap/js/dist/modal'
import 'bootstrap/js/dist/tab'
import 'bootstrap/js/dist/collapse'
import Turbolinks from "turbolinks"

import hljs from 'highlight.js/lib/highlight'
import _crystal from 'highlight.js/lib/languages/crystal'
import _yaml from 'highlight.js/lib/languages/yaml'
hljs.registerLanguage('crystal', _crystal)
hljs.registerLanguage('yaml', _yaml)
window.hljs = hljs

import 'jqcloud2/src/jqcloud'

import moveto from 'moveto/src/moveTo'
window.MoveTo = moveto

import './js/jquery.twbsPagination.js'
import './js/application.js'

Turbolinks.start()
