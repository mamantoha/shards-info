.col-md-4.col-sm-12.shard__statistic
  .list__heading Repository
  p.fw-bold
    = repository.name
  .list__heading Owner
  ul.shard__links.not-list
    li
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repository.user.decorate.avatar(20)}" alt="#{repository.user.login} avatar" loading="lazy"
        .shards__shard_owner_name
          a href="/#{repository.provider}/#{repository.user.login}/"
            = repository.user.login
  .list__heading= "#{repository.provider} statistic"
  ul.repository__statistic.not-list
    li
      i.fas.fa-star title="Stars"
      = repository.stars_count
    li
      i.fas.fa-box title="Used by"
      = repository.dependents.count
    li
      i.fas.fa-code-branch title="Forks"
      = repository.forks_count
    li
      i.fas.fa-exclamation-circle title="Open issues"
      = repository.open_issues_count
    li
      i.fas.fa-rotate title="Last activity"
      = repository.decorate.last_activity_ago
    li
      i.fas.fa-hourglass-start title="Created"
      = repository.created_at.try(&.to_s("%B %-d, %Y"))

  .list__heading License
  p
    = repository.license
  .list__heading Links
  ul.shard__links.not-list
    li
      a href="#{repository.decorate.provider_url}" Homepage
  .list__heading Synced at
  p.small
    = Time::Format::HTTP_DATE.format(repository.synced_at)
  - if repository.languages.any?
    .list__heading Languages
    == render "src/views/repositories/_languages.slang"
