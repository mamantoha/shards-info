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
          h1
            = "#{repository.name}"
            i.page__subheading
              = repository.decorate.latest_release
          .shard__topics
            - repository.tag_names.each do |tag_name|
              a.badge.bg-secondary.text-monospace href="/tags/#{tag_name}" = tag_name
          .shard__intro.text-muted
            span
              == repository.decorate.description_html.to_s
        - if (current_user = current_user(env)) && current_user.admin?
          .col.text-end
            .dropdown#repositoryActions
              button.btn.btn-danger.dropdown-toggle type="button" id="dropdownRepositiryActionsMenuButton" data-bs-toggle="dropdown" aria-expanded="false"
                | Actions
              ul.dropdown-menu.dropdown-menu-dark aria-labelledby="dropdownRepositoryActionsMenuButton"
                li
                  a.dropdown-item#syncRepository href="#" data-href="/admin/repositories/#{repository.id}/sync"
                    i.fas.fa-sync
                    | Sync
                li
                  - if repository.ignore
                    a.dropdown-item#showRepository href="#" data-href="/admin/repositories/#{repository.id}/show"
                      i.fas.fa-eye
                      | Show
                  - else
                    a.dropdown-item#hideRepository href="#" data-href="/admin/repositories/#{repository.id}/hide"
                      i.fas.fa-eye-slash
                      | Hide
                li
                  a.dropdown-item#destroyRepository href="#" data-href="/admin/repositories/#{repository.id}"
                    i.fas.fa-trash-alt
                    | Destroy