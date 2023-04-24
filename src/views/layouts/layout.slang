doctype html
html lang="en"
  head
    - if ENV["GOOGLE_ANALYTICS_ID"]?
      == render "src/views/partials/google_analytics.slang"
    meta charset="utf-8"
    meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"
    meta name="description" content="#{Config.config.page_description}"

    link href="/favicon.ico" rel="shortcut icon" type="image/x-icon"

    == render "src/views/partials/open_graph.slang"

    link rel="stylesheet" href="/dist/application.css?v=#{assets_version}" async="async" defer="defer"
    script src="/dist/application.js?v=#{assets_version}" media="all"

    link rel="icon" sizes="264x168" href="/images/speeddial.png" async="async" defer="defer"

    title #{Config.config.page_title}
  body
    javascript:
      const theme = localStorage.getItem('theme') || 'light';
      document.documentElement.classList.add(theme);
    == render "src/views/partials/navbar.slang"
    == render "src/views/partials/about.slang"
    == render "src/views/partials/back_to_top.slang"
    div role="main"
      == render "src/views/partials/flash.slang"
      == content
    div.space
    footer.footer
      .container.text-center
        span Happy Crystalling ❤️
