ul.shard__links.not-list
  li
    .shards__shard_owner
      .shards__shard_owner_avatar
        img src="#{repository.user.decorate.avatar(20)}" alt="#{repository.user.login} avatar" loading="lazy"
      .shards__shard_owner_name
        = repository.user.login

.shard__intro
  span
    == repository.decorate.description_html.to_s

hr

ul.repository__statistic.not-list
  li
    i.fas.fa-star title="Stars"
    = repository.stars_count
  li
    i.fas.fa-code-branch title="Forks"
    = repository.attributes["forks_count"]
  li
    i.fas.fa-exclamation-circle title="Open issues"
    = repository.open_issues_count
  li
    i.fas.fa-box title="Used by"
    = repository.attributes["dependents_count"]
  li
    i.fas.fa-sitemap title="Dependencies"
    = repository.attributes["dependencies_count"]
  li
    i.fas.fa-rotate title="Last activity"
    = repository.decorate.last_activity_ago
  li
    i.fas.fa-hourglass-start title="Created"
    = repository.created_at.try(&.to_s("%B %-d, %Y"))
