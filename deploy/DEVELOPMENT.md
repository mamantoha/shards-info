## Dump DB on production

```
pg_dump "postgres://postgres@localhost/shards_info_production" -Fc > ~/shards_info_production.sql
```

## Respore DB on localhost

```
psql -c 'DROP DATABASE IF EXISTS shards_info_development;' -U postgres
psql -c 'CREATE DATABASE shards_info_development;' -U postgres

pg_restore -d shards_info_development shards_info_production.sql
```

## Generate new migration

```
crystal src/cli.cr generate migration add_field_to_table
```

## Migrate database

```
crystal src/cli.cr migrate
```

## Update languages color

```
crystal ./src/cli.cr tools update_languages_color
```
