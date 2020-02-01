div
  .page__heading
    .container.shard__header
      h1
        = "#{repository.name}"
        i.page__subheading
          = repository.decorate.latest_release
      .shard__topics
        - repository.tag_names.each do |name|
          a href="/tags/#{name}" class="badge badge-secondary text-monospace" = name
      .shard__intro.text-muted
        span
          == Emoji.emojize(Autolink.auto_link(repository.description.to_s))
.container
  .row
    .col-md-8.col-sm-12.shard__main
      ul class="nav nav-tabs nav-fill" id="infoTab" role="tablist"
        li class="nav-item"
          a class="nav-link active" id="info-tab" href="#info" role="tab" data-toggle="tab" aria-controls="info" aria-selected="true"
            i class="fas fa-info-circle"
            ' Info
        - if repository.readme
          li class="nav-item"
            a class="nav-link" id="readme-tab" href="#readme" role="tab" data-toggle="tab" aria-controls="readme" aria-selected="false"
              i class="fas fa-book"
              ' Readme
        /- if changelog
          li class="nav-item"
            a class="nav-link" id="changelog-tab" href="#changelog" role="tab" data-toggle="tab" aria-controls="changelog" aria-selected="false"
              i class="fas fa-history"
              ' Changelog

      div class="tab-content"
        div role="tabpanel" class="tab-pane fade show active" id="info" aria-labelledby="info-tab"
          == render "src/views/repositories/_info.slang"
        - if repository.readme
          div role="tabpanel" class="tab-pane fade" id="readme" aria-labelledby="readme-tab"
            .row
              .col-md-12.shard__readme
                == readme_html
        /- if changelog
          div role="tabpanel" class="tab-pane fade" id="changelog" aria-labelledby="changelog-tab"
            .row
              .col-md-12.shard__changelog
                == changelog_html

    .col-md-4.col-sm-12.shard__statistic
      .list__heading Owner:
      ul.shard__links.not-list
        li
          .shards__shard_owner
            .shards__shard_owner_avatar
              img src="#{repository.user.decorate.avatar}" alt="#{repository.user.login}"
            .shards__shard_owner_name
              a href="/#{repository.provider}/#{repository.user.login}"
                = repository.user.login
      .list__heading= "#{repository.provider} statistic:"
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

      h3.list__heading License:
      p
        = repository.license
      h3.list__heading Links:
      ul.shard__links.not-list
        li
          a href="#{repository.decorate.provider_url}" Homepage
