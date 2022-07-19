.row
  .col-md-6
    .shard__releases.info-block
      .list__heading
        a data-bs-toggle="collapse" href="#collapseReleases" aria-expanded="true" aria-controls="collapseReleases"
          i class="fa" aria-hidden="true"
          | Latest Releases
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
      .list__heading
        a data-bs-toggle="collapse" href="#collapseDependencies" aria-expanded="true" aria-controls="collapseDependencies"
          i class="fa" aria-hidden="true"
          | Dependencies
      .collapse.show#collapseDependencies
        ul.list__items.not-list
          - dependencies.each do |repository|
            li.link
              i class="#{repository.decorate.provider_icon}"
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true" title="#{render("src/views/repositories/_tooltip.slang")}"
                = repository.name
.row
  .col-md-6
    .shard__dependent_shards.info-block
      .list__heading
        a data-bs-toggle="collapse" href="#collapseDependent" aria-expanded="true" aria-controls="collapseDependent"
          i class="fa" aria-hidden="true"
          | Used by (#{dependents_count})
      .collapse.show#collapseDependent
        ul.list__items.not-list
          - dependents.limit(10).each do |repository|
            li.link
              i class="#{repository.decorate.provider_icon}"
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true" title="#{render("src/views/repositories/_tooltip.slang")}"
                = repository.name
        - if dependents_count > 10
          .shard__see_all_link
            a class="shard__see_all_link" href="/#{repository.provider}/#{repository.decorate.full_name}/dependents"
              ' Show all dependents
  .col-md-6
    .shard__development_dependencies.info-block
      .list__heading
        a data-bs-toggle="collapse" href="#collapseDevelopmentDependencies" aria-expanded="true" aria-controls="collapseDevelopmentDependencies"
          i class="fa" aria-hidden="true"
          | Development dependencies
      .collapse.show#collapseDevelopmentDependencies
        ul.list__items.not-list
          - development_dependencies.each do |repository|
            li.link
              i class="#{repository.decorate.provider_icon}"
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true" title="#{render("src/views/repositories/_tooltip.slang")}"
                = repository.name
