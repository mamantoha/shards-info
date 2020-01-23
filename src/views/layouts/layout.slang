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
    meta name="description" content="#{Config.config.page_description}"
    == render "src/views/partials/open_graph.slang"

    /! Improve Load time by preloading render blocking resources
    link rel="preload" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" as="style"
    link rel="preload" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css" as="style"

    link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous"
    link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css"
    link rel="stylesheet" href="/css/crystal-shards.css?v=1.3"

    title #{Config.config.page_title}
    link href="/images/favicon.ico" rel="shortcut icon" type="image/x-icon"
  body
    == render "src/views/partials/navbar.slang"
    == render "src/views/partials/about.slang"
    == render "src/views/partials/back_to_top.slang"
    .container
      == render "src/views/partials/flash.slang"
      == content
    div.space
    footer.footer
      .container.text-center
        span class="text-muted" Happy Crystalling ♥
    script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"
    script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"

    link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.9.0/css/all.css" integrity="sha256-PF6MatZtiJ8/c9O9HQ8uSUXr++R9KBYu4gbNG5511WE=" crossorigin="anonymous"

    script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"
    script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/crystal.min.js"
    script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/yaml.min.js"
    script src="https://cdnjs.cloudflare.com/ajax/libs/moveTo/1.7.3/moveTo.min.js"

    script src="/js/crystal-shards.js?v=1.0"
    script src="/js/jquery.twbsPagination.js"
