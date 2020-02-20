div
  .page__heading
    .container.shard__header
      h1
        = "#{repository.name}"
        i.page__subheading
          = repository.decorate.latest_release
      .shard__topics
        - repository.tag_names.each do |tag_name|
          a href="/tags/#{tag_name}" class="badge badge-secondary text-monospace" = tag_name
      .shard__intro.text-muted
        span
          == Emoji.emojize(Autolink.auto_link(repository.description.to_s))
.container
  .row
    .col-md-8.col-sm-12.shard__main
      nav id="infoTab" aria-label="Information"
        div class="nav nav-tabs nav-fill justify-content-center" id="nav-tabs" role="tablist"
          a class="nav-item nav-link active" id="info-tab" href="#info" role="tab" data-toggle="tab" aria-controls="info" aria-selected="true"
            i class="fas fa-info-circle"
            ' Info
          - if repository.readme
            a class="nav-item nav-link" id="readme-tab" href="#readme" role="tab" data-toggle="tab" aria-controls="readme" aria-selected="false"
              i class="fas fa-book"
              ' Readme

      div class="tab-content"
        div role="tabpanel" class="tab-pane fade show active" id="info" aria-labelledby="info-tab"
          == render "src/views/repositories/_info.slang"
        - if repository.readme
          div role="tabpanel" class="tab-pane fade" id="readme" aria-labelledby="readme-tab"
            .row
              .col-md-12.shard__readme
                == readme_html

    .col-md-4.col-sm-12.shard__statistic
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
          i class="fas fa-star" title="Stars"
          = repository.stars_count
        li
          i class="fas fa-box" title="Used by"
          = repository.dependents.count
        li
          i class="fas fa-code-branch" title="Forks"
          = repository.forks_count
        li
          i class="fas fa-exclamation-circle" title="Open issues"
          = repository.open_issues_count
        li
          i class="fas fa-clock" title="Last update"
          = repository.decorate.last_activity_ago
        li
          i class="fas fa-hourglass-start" title="Created"
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
