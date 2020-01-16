.row
  .col-md-8.col-sm-12.shard__main
    .page__heading
      h1= repository.name
        /i.page__subheading
          = repo.latest_release
      /- if repo.fork == true
        - parent_repo = repo.parent.not_nil!
        p.fork-flag
          | forked from
          a href="/repos/#{parent_repo.full_name}" = parent_repo.full_name
      .shard__topics
        - repository.tag_names.each do |name|
          a href="/tags/#{name}" class="badge badge-secondary" = name
    .shard__intro
      span
        == Emoji.emojize(Autolink.auto_link(repository.description.to_s))
      /- if repo_homepage = repo.homepage
        span
          a href="#{repo_homepage}" = repo_homepage
    ul class="nav nav-tabs nav-fill" id="infoTab" role="tablist"
      li class="nav-item"
        a class="nav-link active" id="info-tab" href="#info" role="tab" data-toggle="tab" aria-controls="info" aria-selected="true"
          i class="fas fa-info-circle"
          ' Info
      /- if readme
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
        == render "src/views/repo/info.slang"
      /- if readme
        div role="tabpanel" class="tab-pane fade" id="readme" aria-labelledby="readme-tab"
          .row
            .col-md-12.shard__readme
              == readme_html
      /- if changelog
        div role="tabpanel" class="tab-pane fade" id="changelog" aria-labelledby="changelog-tab"
          .row
            .col-md-12.shard__changelog
              == changelog_html

  .col-md-4.col-sm-12
    .list__heading= "#{repository.provider} statistic:"
    ul.shard__statistic.not-list
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
        = "#{HumanizeTime.distance_of_time_in_words(repository.last_activity_at, Time.local)} ago"

    h3.list__heading License:
    /p
      = repo.license_name
    h3.list__heading Links:
    ul.shard__links.not-list
      li
        a href="#{repository.provider_url}" Homepage
