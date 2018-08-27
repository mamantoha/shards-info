# shards-info

View of all repositories on GitHub that have Crystal code in them.

## Installation

* [Install](https://crystal-lang.org/docs/installation/) Crystal
* Clone this repository
* Install dependencies `shards install`
* Rename `.env.example` to `.env`, and set `GITHUB_KEY` and `GITHUB_KEY`
* Run it `source .env && crystal src/shards-info.cr`

## Development

Install [sentry](https://github.com/samueleaton/sentry) to build/runs application,
watches files, and rebuilds/restarts app on file changes.

```console
source .env && sentry
```

### Deploy

Get started by deploying this service to heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

```console
heroku buildpacks:add https://github.com/crystal-lang/heroku-buildpack-crystal.git
```

And set environment variables with `heroku config:set VAR=VAL`:

```console
GITHUB_USER
GITHUB_KEY
SENTRY_DSN
```

Go to https://github.com/settings/tokens and generate new token (select `repo` scope).

On Heroku you **must** enable [Dyno Metadata](https://devcenter.heroku.com/articles/dyno-metadata)
for Sentry's release detection to work correctly.

Run:

```console
heroku labs:enable runtime-dyno-metadata
```

## Built With

* [Crystal language](https://crystal-lang.org/)
* [Kemal](https://github.com/kemalcr/kemal) - Web microframework for Crystal

## Contributing

1. Fork it ( https://github.com/mamantoha/shards-info/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

* [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer
