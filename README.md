# crystal-shards

TODO: Write a description here

## Installation

* Install Redis
* [Install](https://crystal-lang.org/docs/installation/) Crystal
* Clone this repository
* Install dependencies `shards install`
* Run it `crystal src/crystal-shards.cr`

### Deploy

```
heroku buildpacks:add https://github.com/crystal-lang/heroku-buildpack-crystal.git
heroku buildpacks:add -i 1 https://github.com/heroku/heroku-buildpack-redis.git
```

And set environment variables with `heroku config:set VAR=VAL`:

```
GITHUB_USER
GITHUB_KEY
```

## Contributing

1. Fork it ( https://github.com/mamantoha/crystal-shards/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer
