div
  h1.page__heading
    .container
      .h1
        ' Stats
      .h6.font-weight-light
        ' Crystal shards and repositories ecosystem statistics

.container
  .row.mb-4
    .col-md-3
      .card
        .card-header
          ' Repositories
        .card-body
          h2.cart-title.text-end
            = repositories_count
          p.card-text
            i.fas.fa-arrow-up
            = "#{repositories_count_in_last_month} from last month"
          a.btn.btn-primary href="/repositories"
            ' Browse repositories
  .row.mb-4
    .col-md-12
      h3
        ' Growth of the shards.info registry
      p
        = "There are #{users_count} users or teams that have a shards on shards.info."
      p
        = "shards.info has indexed #{repositories_count} repositories."
      #chartRepositoriesGrowth
  .row.mb-4
    .col-md-6
      #chartCreatedAt
    .col-md-6
      #chartLastActivityAt
  .row.mb-4
    .col-md-12
      h3
        ' Number of direct dependencies
      p
        ' Number of libraries explicitly used by each shard. Includes dev dependencies.
      #chartDirectDependencies
  .row.mb-4
    .col-md-12
      h3
        ' Number of transitive reverse dependencies (popularity)
      p
        ' How often each library shard is used as a dependency in other shards. Includes dev dependencies.
      #chartReverseDependencies
  .row.mb-4
    .col-md-12
      h3
        ' Number of shards per user
      p
        ' How many shards a single account (user or team) owns.
      #chartUserRepositoriesCount
