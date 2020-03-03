doctype html
html lang="en"
  head
    - if ENV["GOOGLE_ANALYTICS_ID"]?
      javascript:
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        ga("create", "#{ENV["GOOGLE_ANALYTICS_ID"]}", "auto");

    meta charset="utf-8"
    meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"
    meta name="description" content="#{Config.config.page_description}"
    meta name="turbolinks-cache-control" content="no-preview"

    link href="/favicon.ico" rel="shortcut icon" type="image/x-icon"

    == render "src/views/partials/open_graph.slang"

    link rel="stylesheet" href="/dist/application.css?v=2.3" async="async" defer="defer"
    script src="/dist/application.js?v=2.2" media="all"

    title #{Config.config.page_title}
  body
    == render "src/views/partials/navbar.slang"
    == render "src/views/partials/about.slang"
    == render "src/views/partials/back_to_top.slang"
    div role="main"
      == content
    div.space
    footer.footer
      .container.text-center
        span Happy Crystalling ♥
