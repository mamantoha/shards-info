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

    link rel="stylesheet" href="/dist/application.css?v=4.13" async="async" defer="defer"
    script src="/dist/application.js?v=4.7" media="all"

    title #{Config.config.page_title}
  body
    == render "src/views/partials/navbar.slang"
    == render "src/views/partials/about.slang"
    == render "src/views/partials/back_to_top.slang"
    div role="main"
      #standWithUkraine.d-none.d-lg-block
        .blue-band
          p.mb-0
            | This software was created by a developer from Ukraine.
          p.mb-0
            | Russia has invaded Ukraine and already killed thousands of civilians, including more than 40 children.
          p
            | The death toll is still counting. It is a war and we need your help. Let's stand together against the Russian regime.
        .yellow-band
          span
            a.btn.btn-outline-primary href="https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md" Read more
            a.button.btn.btn-outline-primary href="https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/Donate.md" Support Ukraine
          p.text-end.hashtag
            | #StandWithUkraine

      /div.alert.alert-danger.text-center role="alert"
        | 🇺🇦 Русский военный корабль, иди на хуй!
      == render "src/views/partials/flash.slang"
      == content
    div.space
    footer.footer
      .container.text-center
        span Happy Crystalling ♥
