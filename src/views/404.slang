doctype html
html lang="en"
  head
    meta charset="utf-8"
    meta http-equiv="X-UA-Compatible" content="IE=edge"
    meta name="viewport" content="width=device-width, initial-scale=1"
    meta name="color-scheme" content="light dark"

    title Page not found

    link href="/favicon.ico" rel="shortcut icon" type="image/x-icon"

    link type="text/css" rel="stylesheet" href="/css/404.css"
  body
    #notfound
      .notfound
        .notfound-404
          h1 404
        h2 Oops, The Page you are looking for can't be found!
        form.notfound-search action="/search" method="GET" autocomplete="off"
          input aria-label="Search" name="query" type="text" placeholder="Search shards..." onClick="this.select();"
          button type="submit" Search
        a href="/"
          span.arrow
          | Back to Homepage
