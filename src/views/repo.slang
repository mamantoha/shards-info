.row
  .col-md-8.col-sm-12.shard__main
    .page__heading
      h1= repo.name
        i.page__subheading
          = repo.latest_release
      .shard__topics
        - if topics = repo.topics
          - topics.each do |topic|
            a href="/repos?query=topic:#{topic}" class="badge badge-secondary" = topic
    .shard__intro
      == Emoji.emojize(Autolink.auto_link(repo.description.to_s))
    ul class="nav nav-tabs nav-fill" id="infoTab" role="tablist"
      li class="nav-item"
        a class="nav-link active" id="info-tab" href="#info" role="tab" data-toggle="tab" aria-controls="info" aria-selected="true"
          i class="fas fa-info-circle"
          ' Info
      - if readme
        li class="nav-item"
          a class="nav-link" id="readme-tab" href="#readme" role="tab" data-toggle="tab" aria-controls="readme" aria-selected="false"
            i class="fas fa-book"
            ' Readme
      - if changelog
        li class="nav-item"
          a class="nav-link" id="changelog-tab" href="#changelog" role="tab" data-toggle="tab" aria-controls="changelog" aria-selected="false"
            i class="fas fa-history"
            ' Changelog

    div class="tab-content"
      div role="tabpanel" class="tab-pane fade show active" id="info" aria-labelledby="info-tab"
        == render "src/views/repo/info.slang"
      - if readme
        div role="tabpanel" class="tab-pane fade" id="readme" aria-labelledby="readme-tab"
          .row
            .col-md-12.shard__readme
              == readme_html
      - if changelog
        div role="tabpanel" class="tab-pane fade" id="changelog" aria-labelledby="changelog-tab"
          .row
            .col-md-12.shard__changelog
              == changelog_html

  .col-md-4.col-sm-12
    .list__heading Github statistic:
    ul.shard__statistic.not-list
      li
        i class="fas fa-star" title="Stars"
        = repo.watchers_count
      li
        i class="fas fa-code-branch" title="Forks"
        = repo.forks_count
      li
        i class="fas fa-eye" title="Watchers"
        = repo.subscribers_count
      li
        i class="fas fa-exclamation-circle" title="Open issues"
        = repo.open_issues_count
      li
        i class="fas fa-clock" title="Last update"
        | #{HumanizeTime.distance_of_time_in_words(repo.updated_at, Time.now)} #{I18n.translate("ago")}

    h3.list__heading License:
    p
      = repo.license_name
    h3.list__heading Links:
    ul.shard__links.not-list
      li
        a href="#{repo.html_url}" Homepage
