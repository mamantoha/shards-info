.row
  .col-md-6
    .shard__releases.info-block
      h3.list__heading
        a data-toggle="collapse" href="#collapseReleases" aria-expanded="true" aria-controls="collapseReleases"
          i class="fa" aria-hidden="true"
          | Latest Releases:
      .collapse.show#collapseReleases
        ul.list__items.not-list
          - repository.releases.order_by(published_at: :desc).limit(5).each do |release|
            li.shard__release-wrap
              = release.tag_name
              small
                ' -
                = release.published_at.try(&.to_s("%B %-d, %Y"))
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
              i class="#{repository.decorate.provider_icon}"
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" = repository.name
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
              i class="#{repository.decorate.provider_icon}"
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" = repository.name
        - if dependents_count > 10
          .shard__see_all_link
            a class="shard__see_all_link" href="/#{repository.provider}/#{repository.decorate.full_name}/dependents"
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
              i class="#{repository.decorate.provider_icon}"
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" = repository.name
