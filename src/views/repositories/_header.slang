div
  .page__heading
    .container.shard__header
      - if repository.archived
        .row
          .col
            .archived-repository.alert.alert-warning.text-center
              | This repository has been archived by the owner. It is now read-only.
      .row
        .col
          h1.mb-0
            = repository.name
            i.page__subheading
              = repository.decorate.latest_release
          span.small
            - if repository.fork
              | forked from
              - if (repository_parent = repository.repository_parent)
                a href="#{repository_parent.parent.decorate.show_path}"
                  = repository_parent.parent.decorate.full_name
          .shard__topics.mt-2
            - repository.tags.each do |tag|
              a.badge.bg-secondary.text-monospace href="/tags/#{tag.name}" = tag.name
          .shard__intro
            span
              == repository.decorate.description_html.to_s
        - if (current_user = current_user(env)) && current_user.admin?
          .col.text-end
            .dropdown#repositoryActions
              button.btn.btn-danger.dropdown-toggle type="button" id="dropdownRepositoryActionsMenuButton" data-bs-toggle="dropdown" aria-expanded="false"
                | Actions
              ul.dropdown-menu aria-labelledby="dropdownRepositoryActionsMenuButton"
                li
                  a.dropdown-item.js-action href="#" data-href="/admin/repositories/#{repository.id}/sync" data-method="POST"
                    i.fas.fa-sync
                    | Sync
                li
                  - if repository.ignore
                    a.dropdown-item.js-action href="#" data-href="/admin/repositories/#{repository.id}/show" data-method="POST"
                      i.fas.fa-eye
                      | Show
                  - else
                    a.dropdown-item.js-action href="#" data-href="/admin/repositories/#{repository.id}/hide" data-method="POST"
                      i.fas.fa-eye-slash
                      | Hide
                li
                  a.dropdown-item.js-action href="#" data-href="/admin/repositories/#{repository.id}" data-method="DELETE"
                    i.fas.fa-trash-alt
                    | Destroy
