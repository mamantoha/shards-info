doctype html
html lang="en"
  head
    meta charset="utf-8"
    meta http-equiv="X-UA-Compatible" content="IE=edge"
    meta name="viewport" content="width=device-width, initial-scale=1"

    title Page not found

    link type="text/css" rel="stylesheet" href="/css/404.css"
  body
    #notfound
      .notfound
        .notfound-404
          h1 404
        h2 Oops, The Page you are looking for can't be found!
        form.notfound-search action="/search" method="GET" autocomplete="off"
          input name="query" type="text" placeholder="Search shards..." onClick="this.select();"
          button type="button" Search
        a href="/"
          span.arrow
          | Back to Homepage
