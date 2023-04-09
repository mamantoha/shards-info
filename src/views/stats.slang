div
  h1.page__heading
    .container
      .h1
        ' Stats
      .h6.font-weight-light
        ' Crystal shards and repositories ecosystem statistics

.container
  .row
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
    .col-md-3
      .card
        .card-header
          ' Users
        .card-body
          h2.cart-title.text-end
            = users_count
          p.card-text
            i.fas.fa-arrow-up
            = "#{users_count_in_last_month} from last month"
          a.btn.btn-primary href="/users"
            ' Browse users

  .row
    .col-md-12
      #chartRepositoriesGrowth
  .row
    .col-md-6
      #chartCreatedAt
    .col-md-6
      #chartLastActivityAt
  .row
    .col-md-6
    .col-md-6
