.container.mt-5
  .h1
    | About
  .h6.font-weight-light
    | View of all repositories on Github and Gitlab that have Crystal code in them.

  ul
    li
      | Build with:
      ul
        li
          a href="https://crystal-lang.org" Crystal
          = Crystal::VERSION
        li
          a href="https://kemalcr.com/" Kemal
          = Kemal::VERSION
        li
          a href="https://github.com/mamantoha/clear" Clear
          = Clear::VERSION
        li
          a href="https://github.com/mosquito-cr/mosquito" Mosquito
          = Mosquito::VERSION
        li
          a href="https://nodejs.org/" Node.js
          = Config.nodejs_version
        li
          a href="https://postgresql.org/" PostgreSQL
          = Config.postgres_version
        li
          a href="https://redis.io/" Redis
          = Config.redis_version
    li
      | Build date #{Time.parse_rfc2822(Config.date).to_s("%Y-%m-%d %H:%M:%S %:z")}
    li
      | Official code repository is on
      a href="https://github.com/mamantoha/shards-info" Github
    li
      | Developed and maintained by
      a href="mailto:anton.maminov@gmail.com" Anton Maminov
  .px-4.mt-3
    | We hope that this site will encourage you to start your own Crystal projects!
