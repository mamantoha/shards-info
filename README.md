# shards-info

[![Build Status](https://travis-ci.org/mamantoha/shards-info.svg?branch=master)](https://travis-ci.org/mamantoha/shards-info)

View of all repositories on GitHub that have Crystal code in them.

## Installation

* [Install](https://crystal-lang.org/docs/installation/) Crystal
* Clone this repository
* Install dependencies `shards install`
* Rename `.env.example` to `.env`, and set `GITHUB_USER` and `GITHUB_KEY`
* Run it `source .env && crystal src/shards-info.cr`

## Development

Install [sentry](https://github.com/samueleaton/sentry) to build/runs application,
watches files, and rebuilds/restarts app on file changes.

```console
source .env && sentry
```

## Specs

```console
source .env && export KEMAL_ENV=test && crystal spec
```

## Built With

* [Crystal language](https://crystal-lang.org/)
* [Kemal](https://github.com/kemalcr/kemal) - Web microframework for Crystal

## Contributing

1. Fork it (<https://github.com/mamantoha/shards-info/fork>)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

* [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer
