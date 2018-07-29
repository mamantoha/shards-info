doctype html
html lang="en"
  head
    - if ENV["GOOGLE_ANALYTICS_ID"]?
      /! Global site tag (gtag.js) - Google Analytics
      script async="" src="https://www.googletagmanager.com/gtag/js?id=#{ENV["GOOGLE_ANALYTICS_ID"]}"
      javascript:
        | window.dataLayer = window.dataLayer || [];
        | function gtag(){dataLayer.push(arguments);}
        | gtag('js', new Date());

        | gtag('config', '#{ENV["GOOGLE_ANALYTICS_ID"]}');

    meta charset="utf-8"
    meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"
    meta name="description" content="View of all repositories on GitHub that have Crystal code in them."
    == render "src/views/partials/open_graph.slang"

    link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous"
    link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css"
    link rel="stylesheet" href="/css/crystal-shards.css"

    title #{Config.config.page_title}
    link href="/images/favicon.ico" rel="shortcut icon" type="image/x-icon"
  body
    == render "src/views/partials/navbar.slang"
    == render "src/views/partials/about.slang"
    .container
      == render "src/views/partials/flash.slang"
      == content
    div.space
    footer.footer
      .container
        span class="text-muted" Shards Info
    script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"
    script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"

    link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.2.0/css/all.css" integrity="sha384-hWVjflwFxL6sNzntih27bfxkr27PmbbK/iSvJ+a4+0owXq79v+lsFkW54bOGbiDQ" crossorigin="anonymous"

    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"
    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/crystal.min.js"
    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/yaml.min.js"

    script src="/js/crystal-shards.js"
