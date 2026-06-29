<img src="https://raw.githubusercontent.com/mamantoha/shards-info/master/public/images/logo-horizontal_dark.png" alt="shards.info" width="360" />

[![Built with Crystal](https://img.shields.io/badge/built%20with-Crystal-000000.svg?logo=appveyor)](https://crystal-lang.org/)
[![Crystal CI](https://github.com/mamantoha/shards-info/actions/workflows/crystal.yml/badge.svg)](https://github.com/mamantoha/shards-info/actions/workflows/crystal.yml)
[![Oxc](https://github.com/mamantoha/shards-info/actions/workflows/oxc.yml/badge.svg)](https://github.com/mamantoha/shards-info/actions/workflows/oxc.yml)

View of all repositories on Github and Gitlab that have Crystal code in them.

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-single.svg)](https://vshymanskyy.github.io/StandWithUkraine)

## Installation

- [Install](https://crystal-lang.org/docs/installation/) Crystal
- Clone this repository
- Install dependencies `shards install`
- Rename `.env.example` to `.env`, and set variables.
- Run Web server as `crystal src/web.cr`

## Development

```console
psql -c 'CREATE DATABASE shards_info_development;' -U postgres
crystal src/cli.cr migrate
```

### Database Operations (Makefile)

We use a Makefile to automate database schema dumps and restoration. Available commands:

#### Dump database schema and migrations

```
make db-dump
```

This dumps both the schema and migration metadata (__lustra_metadatas table) into `src/db/structure.sql`.

#### Dump schema only

```
make db-dump-schema
```

#### Dump migrations metadata only

```
make db-dump-migrations
```

#### Restore from dump

```
make db-restore
```

#### Using a different database

```
make db-dump DB_NAME=your_database_name
make db-restore DB_NAME=your_database_name
```

#### View all available commands

```
make help
```

### Frontend

Install depencencies:

```console
npm install
```

After modifications run `npm run build`, `npm run oxlint`, and `npm run oxfmt`.

## Specs

Specs create and migrate their own PostgreSQL test database via `spec/initdb.cr`.
The default connection settings are:

```console
DATABASE_URL=postgres://postgres:postgres@localhost/shards_info_test
POSTGRES_HOST=localhost
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
```

Redis must also be running locally for cache/session/Mosquito/Defense dependencies.
The app uses these defaults in test:

```console
REDIS_URL=redis://localhost:6379/0
SESSION_REDIS_URL=redis://localhost:6379/1
MOSQUITO_REDIS_URL=redis://localhost:6379/2
DEFENSE_REDIS_URL=redis://localhost:6379/3
```

Run specs with:

```console
KEMAL_ENV=test crystal spec
```

To only recreate the test database:

```console
KEMAL_ENV=test crystal spec/initdb.cr
```

## Special thanks

- [Crystal language](https://crystal-lang.org/)
- [Lustra](https://github.com/crystal-garage/lustra) - Advanced ORM between PostgreSQL and Crystal
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
