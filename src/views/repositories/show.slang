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

.container
  .row
    .col-md-8.col-sm-12.shard__main
      nav.infoTab aria-label="Information"
        .nav.nav-tabs.nav-fill.justify-content-center#nav-tabs role="tablist"
          a.nav-item.nav-link.active#info-tab href="#info" role="tab" data-bs-toggle="tab" aria-controls="info" aria-selected="true"
            i.fas.fa-info-circle
            ' Info
          - if repository.readme
            a.nav-item.nav-link#readme-tab href="#readme" role="tab" data-bs-toggle="tab" aria-controls="readme" aria-selected="false"
              i.fas.fa-book
              ' Readme

      .tab-content.mt-4
        .tab-pane.fade.show.active#info role="tabpanel" aria-labelledby="info-tab"
          == render "src/views/repositories/_info.slang"
        - if repository.readme
          .tab-pane.fade#readme role="tabpanel" aria-labelledby="readme-tab"
            .row
              .col-md-12.shard__readme
                == readme_html

    .col-md-4.col-sm-12.shard__statistic
      .list__heading Owner
      ul.shard__links.not-list
        li
          .shards__shard_owner
            .shards__shard_owner_avatar
              img src="#{repository.user.decorate.avatar(20)}" alt="#{repository.user.login} avatar" loading="lazy"
            .shards__shard_owner_name
              a href="/#{repository.provider}/#{repository.user.login}/"
                = repository.user.login
      .list__heading= "#{repository.provider} statistic"
      ul.repository__statistic.not-list
        li
          i.fas.fa-star title="Stars"
          = repository.stars_count
        li
          i.fas.fa-box title="Used by"
          = repository.dependents.count
        li
          i.fas.fa-code-branch title="Forks"
          = repository.forks_count
        li
          i.fas.fa-exclamation-circle title="Open issues"
          = repository.open_issues_count
        li
          i.fas.fa-clock title="Last update"
          = repository.decorate.last_activity_ago
        li
          i.fas.fa-hourglass-start title="Created"
          = repository.created_at.try(&.to_s("%B %-d, %Y"))

      .list__heading License
      p
        = repository.license
      .list__heading Links
      ul.shard__links.not-list
        li
          a href="#{repository.decorate.provider_url}" Homepage
      .list__heading Synced at
      p.small
        = Time::Format::HTTP_DATE.format(repository.synced_at)
