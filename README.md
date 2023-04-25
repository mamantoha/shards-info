<img src="https://raw.githubusercontent.com/mamantoha/shards-info/master/public/images/logo-horizontal_dark.png" alt="shards.info" width="360" />

[![Built with Crystal](https://img.shields.io/badge/built%20with-Crystal-000000.svg?logo=appveyor)](https://crystal-lang.org/)
[![Crystal CI](https://github.com/mamantoha/shards-info/actions/workflows/crystal.yml/badge.svg)](https://github.com/mamantoha/shards-info/actions/workflows/crystal.yml)
[![ESLint](https://github.com/mamantoha/shards-info/actions/workflows/eslint.yml/badge.svg)](https://github.com/mamantoha/shards-info/actions/workflows/eslint.yml)
[![Stylelint](https://github.com/mamantoha/shards-info/actions/workflows/stylelint.yml/badge.svg)](https://github.com/mamantoha/shards-info/actions/workflows/stylelint.yml)

View of all repositories on Github and Gitlab that have Crystal code in them.

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-single.svg)](https://vshymanskyy.github.io/StandWithUkraine)

<p><a href="javascript:alert('XSS attack!')">Hello world!</a></p>

## Installation

- [Install](https://crystal-lang.org/docs/installation/) Crystal
- Clone this repository
- Install dependencies `shards install`
- Rename `.env.example` to `.env`, and set variables.
- Run it `crystal src/shards-info.cr`

## Development

```console
psql -c 'CREATE DATABASE shards_info_development;' -U postgres
crystal src/cli.cr migrate
```

### Frontend

Install depencencies:

```console
npm install
```

After modifications:

1. Run `npm run build`
2. Change version of `application.js` and `application.css` in `src/views/layouts/layout.slang`

## Specs

Prepare a database:

```console
crystal spec/initdb.cr
```

Run specs:

```console
KEMAL_ENV=test crystal spec
```

## Special thanks

- [Crystal language](https://crystal-lang.org/)
- [Clear](https://github.com/anykeyh/clear) - Advanced ORM between PostgreSQL and Crystal
- [Kemal](https://github.com/kemalcr/kemal) - Web microframework for Crystal
- [Mosquito](https://github.com/robacarp/mosquito) - A generic background task runner for Crystal applications
- [raven.cr](https://github.com/Sija/raven.cr) - Crystal client for [Sentry](https://sentry.io)
- [cr-cmark-gfm](https://github.com/amauryt/cr-cmark-gfm) - Crystal C bindings for [cmark-gfm](https://github.com/github/cmark-gfm)
- [noir](https://github.com/MakeNowJust/noir) - Syntax Highlight Library for Crystal
- Logo [icon](https://game-icons.net/1x1/lorc/floating-crystal.html) taken from [Game Icons pack](https://game-icons.net/) under CC BY 3.0 license.

## Contributing

1. Fork it (<https://github.com/mamantoha/shards-info/fork>)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer
