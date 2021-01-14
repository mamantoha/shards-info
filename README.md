<img src="https://raw.githubusercontent.com/mamantoha/shards-info/master/public/images/logo-horizontal_dark.png" alt="shards.info" width="360" />

[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=for-the-badge&logo=appveyor)](https://crystal-lang.org/)
![Travis (.org) branch](https://img.shields.io/travis/mamantoha/shards-info/master?style=for-the-badge)

View of all repositories on Github and Gitlab that have Crystal code in them.

## Installation

* [Install](https://crystal-lang.org/docs/installation/) Crystal
* Clone this repository
* Install dependencies `shards install`
* Rename `.env.example` to `.env`, and set variables.
* Run it `crystal src/shards-info.cr`

## Development

```console
psql -c 'CREATE DATABASE shards_info_development;' -U postgres
crystal src/db.cr migrate
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

```console
export KEMAL_ENV=test && crystal spec
```

## Special thanks

* [Crystal language](https://crystal-lang.org/)
* [Clear](https://github.com/anykeyh/clear) - Advanced ORM between PostgreSQL and Crystal
* [Kemal](https://github.com/kemalcr/kemal) - Web microframework for Crystal
* [Mosquito](https://github.com/robacarp/mosquito) - A generic background task runner for Crystal applications
* [raven.cr](https://github.com/Sija/raven.cr) - Crystal client for [Sentry](https://sentry.io)
* Logo [icon](https://game-icons.net/1x1/lorc/floating-crystal.html) taken from [Game Icons pack](https://game-icons.net/) under CC BY 3.0 license.

## Contributing

1. Fork it (<https://github.com/mamantoha/shards-info/fork>)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

* [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer
