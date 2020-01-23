.row
  .col-md-6
    /.shard__releases.info-block
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
    .shard__dependencies.info-block
      h3.list__heading
        a data-toggle="collapse" href="#collapseDependencies" aria-expanded="true" aria-controls="collapseDependencies"
          i class="fa" aria-hidden="true"
          | Dependencies:
      .collapse.show#collapseDependencies
        ul.list__items.not-list
          - repository.dependencies.with_user.where { relationships.development == false }.each do |repository|
            li
              i class="#{repository.provider_icon}"
              a href="/#{repository.provider}/#{repository.user.login}/#{repository.name}" = repository.name
.row
  .col-md-6
    .shard__dependent_shards.info-block
      h3.list__heading
        a data-toggle="collapse" href="#collapseDependent" aria-expanded="true" aria-controls="collapseDependent"
          i class="fa" aria-hidden="true"
          | Used by (#{dependents_count}):
      .collapse.show#collapseDependent
        ul.list__items.not-list
          - dependents.with_user.limit(10).each do |repository|
            li
              i class="#{repository.provider_icon}"
              a href="/#{repository.provider}/#{repository.user.login}/#{repository.name}" = repository.name
        - if dependents_count > 10
          .shard__see_all_link
            a class="shard__see_all_link" href="/#{repository.provider}/#{repository.user.login}/#{repository.name}/dependents"
              ' Show all dependents
  .col-md-6
    .shard__development_dependencies.info-block
      h3.list__heading
        a data-toggle="collapse" href="#collapseDevelopmentDependencies" aria-expanded="true" aria-controls="collapseDevelopmentDependencies"
          i class="fa" aria-hidden="true"
          | Development dependencies:
      .collapse.show#collapseDevelopmentDependencies
        ul.list__items.not-list
          - repository.dependencies.with_user.where { relationships.development == true }.each do |repository|
            li
              i class="#{repository.provider_icon}"
              a href="/#{repository.provider}/#{repository.user.login}/#{repository.name}" = repository.name
.row
  .col-12
    .shard__owner
      h3.list__heading Owner:
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repository.user.avatar}" alt="#{repository.user.login}"
        .shards__shard_owner_name
          a href="/#{repository.provider}/#{repository.user.login}" = repository.user.login
