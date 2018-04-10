.row
  .col-md-8.col-sm-12.shard__main
    .page__heading
      h1= repo.name
        i.page__subheading
          = repo.latest_release
      .shard__topics
        - if topics = repo.topics
          - topics.each do |topic|
            a href="/repos?query=topic:#{topic}" class="badge badge-pill badge-primary" = topic
    .shard__intro
      == Emoji.emojize(Autolink.auto_link(repo.description.to_s, html: {"target" => "_blank"}))
    ul class="nav nav-tabs" id="infoTab" role="tablist"
      li class="nav-item"
        a class="nav-link active" id="info-tab" href="#info" role="tab" data-toggle="tab" aria-controls="info" aria-selected="true"
          i class="fas fa-info-circle"
          ' Info
      - if readme
        li class="nav-item"
          a class="nav-link" id="readme-tab" href="#readme" role="tab" data-toggle="tab" aria-controls="readme" aria-selected="false"
            i class="fas fa-book"
            ' Readme

    div class="tab-content"
      div role="tabpanel" class="tab-pane fade show active" id="info" aria-labelledby="info-tab"
        == render "src/views/repo/info.slang"
      - if readme
        div role="tabpanel" class="tab-pane fade" id="readme" aria-labelledby="readme-tab"
          .row
            .col-md-12.shard__readme
              == readme_html

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
        = "#{HumanizeTime.distance_of_time_in_words(repo.pushed_at, Time.now)} ago"

    h3.list__heading License:
    p
      = repo.license_name
    h3.list__heading Links:
    ul.shard__links.not-list
      li
        a href="#{repo.html_url}" target="_blank" Homepage
