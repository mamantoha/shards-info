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
    link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"
    link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css"
    link rel="stylesheet" href="/css/crystal-shards.css"
    title #{Config.config.page_title}
    link href="/favicon.ico" rel="shortcut icon" type="image/x-icon"
  body
    nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top"
      .container
        a class="navbar-brand" href="/"
          img src="/logo.svg" width="30" height="30" class="d-inline-block align-top" alt=""
          ' Crystal Shards
        button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"
          span class="navbar-toggler-icon"
        div class="collapse navbar-collapse" id="navbarSupportedContent"
          ul class="navbar-nav mr-auto"
          == render "src/views/partials/search_input.slang"
    .container
      == render "src/views/partials/flash.slang"
      == content
    div.space
    footer.footer
      .container
        span class="text-muted" Crystal Shards
    script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"
    script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"
    script src="https://use.fontawesome.com/releases/v5.0.8/js/solid.js" integrity="sha384-+Ga2s7YBbhOD6nie0DzrZpJes+b2K1xkpKxTFFcx59QmVPaSA8c7pycsNaFwUK6l" crossorigin="anonymous"
    script src="https://use.fontawesome.com/releases/v5.0.8/js/brands.js" integrity="sha384-sCI3dTBIJuqT6AwL++zH7qL8ZdKaHpxU43dDt9SyOzimtQ9eyRhkG3B7KMl6AO19" crossorigin="anonymous"
    script src="https://use.fontawesome.com/releases/v5.0.8/js/fontawesome.js" integrity="sha384-7ox8Q2yzO/uWircfojVuCQOZl+ZZBg2D2J5nkpLqzH1HY0C1dHlTKIbpRz/LG23c" crossorigin="anonymous"
    /! https://cdnjs.com/libraries/highlight.js/
    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"
    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/crystal.min.js"
    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/yaml.min.js"
    script src="/js/crystal-shards.js"
