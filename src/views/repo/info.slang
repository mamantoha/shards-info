.row
  .col-md-6
    .shard__releases
      h3.list__heading
        a data-toggle="collapse" href="#collapseReleases" aria-expanded="true" aria-controls="collapseReleases"
          i class="fa" aria-hidden="true"
          | Releases:
      .collapse.show#collapseReleases
        ul.list__items.not-list
          - repo.releases.first(5).each do |release|
            li.shard__release-wrap
              = release.tag_name
              small
                ' -
                = release.published_at.to_s("%B %-d, %Y")
  .col-md-6
    .shard__dependencies
      h3.list__heading
        a data-toggle="collapse" href="#collapseDependencies" aria-expanded="true" aria-controls="collapseDependencies"
          i class="fa" aria-hidden="true"
          | Dependencies:
      .collapse.show#collapseDependencies
        ul.list__items.not-list
          - dependencies.each do |key, value|
            li
              i class="fab fa-github"
              - if value["github"]?
                a href="/repos/#{value["github"]}" = key
              - else
                = key
.row
  .col-md-6
    .shard__dependent_shards
      h3.list__heading
        a data-toggle="collapse" href="#collapseDependent" aria-expanded="true" aria-controls="collapseDependent"
          i class="fa" aria-hidden="true"
          | Dependent shards (#{dependent_repos.total_count}):
      .collapse.show#collapseDependent
        ul.list__items.not-list
          - dependent_repos.items.each do |item|
            li
              i class="fab fa-github"
              a href="/repos/#{item.repository.full_name}" = item.repository.name
        - if dependent_repos.total_count > 10
          .shard__see_all_dependent_link
            a class="shard__see_all_dependent_link" href="/repos/#{repo.full_name}/dependents"
              ' Show all dependents
  .col-md-6
      .shard__development_dependencies
        h3.list__heading
          a data-toggle="collapse" href="#collapseDevelopmentDependencies" aria-expanded="true" aria-controls="collapseDevelopmentDependencies"
            i class="fa" aria-hidden="true"
            | Development dependencies:
        .collapse.show#collapseDevelopmentDependencies
          ul.list__items.not-list
            - development_dependencies.each do |key, value|
              li
                i class="fab fa-github"
                - if value["github"]?
                  a href="/repos/#{value["github"]}" = key
                - else
                  = key
.row
  .col-12
    .shard__owner
      h3.list__heading Owner:
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repo.owner.avatar_url}" alt="#{repo.owner.login}"
        .shards__shard_owner_name
          a href="/repos/#{repo.owner.login}" = repo.owner.login
