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

    == render "src/views/partials/open_graph.slang"

    link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous"
    link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.9.0/css/all.css" integrity="sha256-PF6MatZtiJ8/c9O9HQ8uSUXr++R9KBYu4gbNG5511WE=" crossorigin="anonymous"
    link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"
    link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.1/styles/github.min.css" integrity="sha256-iAmWN8uaUdN6Y9FCf8srQdrx3eVVwouJ5QtEiyuTQ6A=" crossorigin="anonymous"
    link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/jqcloud2@2.0.3/dist/jqcloud.min.css" integrity="sha256-UjwN98m8Dcz5FTMPDMCkUoRCMmtV8U0uTsX7fMiBlYU=" crossorigin="anonymous"
    link rel="stylesheet" href="/css/crystal-shards.css?v=1.8"

    script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"
    script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"
    script src="https://cdn.jsdelivr.net/npm/jqcloud2@2.0.3/dist/jqcloud.min.js" integrity="sha256-+krhsKJpvd3AZYVGHcwyCUGO01uNdGSTvqR7Apcy30E=" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.1/highlight.min.js" integrity="sha256-eOgo0OtLL4cdq7RdwRUiGKLX9XsIJ7nGhWEKbohmVAQ=" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.1/languages/crystal.min.js" integrity="sha256-eDgKRIlXD0xkJA9dV0U0BEpEJORNZASvCDSBv+f0SsA=" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.1/languages/yaml.min.js" integrity="sha256-z6ne2FeT9mH7gdPHHc68W8MwdnePuf9rR2cln3lt2hQ=" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/moveTo/1.7.3/moveTo.min.js"
    script src="/js/jquery.twbsPagination.js?v=1.0"
    script src="/js/crystal-shards.js?v=1.5"

    script src="https://cdnjs.cloudflare.com/ajax/libs/turbolinks/5.2.0/turbolinks.js" integrity="sha256-iM4Yzi/zLj/IshPWMC1IluRxTtRjMqjPGd97TZ9yYpU=" crossorigin="anonymous"

    title #{Config.config.page_title}
    link href="/images/favicon.ico" rel="shortcut icon" type="image/x-icon"
  body
    == render "src/views/partials/navbar.slang"
    == render "src/views/partials/about.slang"
    == render "src/views/partials/back_to_top.slang"
    == content
    div.space
    footer.footer
      .container.text-center
        span class="text-muted" Happy Crystalling ♥
