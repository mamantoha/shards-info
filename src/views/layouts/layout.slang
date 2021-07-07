doctype html
html lang="en"
  head
    - if ENV["GOOGLE_ANALYTICS_ID"]?
      /! Global site tag (gtag.js) - Google Analytics
      script async="async" src="https://www.googletagmanager.com/gtag/js?id=#{ENV["GOOGLE_ANALYTICS_ID"]}""
      javascript:
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', '#{ENV["GOOGLE_ANALYTICS_ID"]}');

    meta charset="utf-8"
    meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"
    meta name="description" content="#{Config.config.page_description}"
    meta name="turbolinks-cache-control" content="no-preview"

    link href="/favicon.ico" rel="shortcut icon" type="image/x-icon"

    == render "src/views/partials/open_graph.slang"

    link rel="stylesheet" href="/dist/application.css?v=4.6" async="async" defer="defer"
    script src="/dist/application.js?v=4.3" media="all"

    title #{Config.config.page_title}
  body
    == render "src/views/partials/navbar.slang"
    == render "src/views/partials/about.slang"
    == render "src/views/partials/back_to_top.slang"
    div role="main"
      == render "src/views/partials/flash.slang"
      == content
    div.space
    footer.footer
      .container.text-center
        span Happy Crystalling ♥
