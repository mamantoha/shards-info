.page__heading.user_heading
  .container.text-center
    - if (current_user = current_user(env)) && current_user.admin?
      .text-end
        .dropdown#userActions
          button.btn.btn-danger.dropdown-toggle type="button" id="dropdownUserActionsMenuButton" data-bs-toggle="dropdown" aria-expanded="false"
            | Actions
          ul.dropdown-menu.dropdown-menu-dark aria-labelledby="dropdownUserActionsMenuButton"
            li
              a.dropdown-item.js-action href="#" data-href="/admin/users/#{user.id}/sync" data-method="POST"
                i.fas.fa-sync
                | Sync
            li
              - if user.ignore
                a.dropdown-item.js-action href="#" data-href="/admin/users/#{user.id}/show" data-method="POST"
                  i.fas.fa-eye
                  | Show
              - else
                a.dropdown-item.js-action href="#" data-href="/admin/users/#{user.id}/hide" data-method="POST"
                  i.fas.fa-eye-slash
                  | Hide
            li
              a.dropdown-item.js-action href="#" data-href="/admin/users/#{user.id}" data-method="DELETE"
                i.fas.fa-trash-alt
                | Destroy
    .user__avatar
      img src="#{user.decorate.avatar(90)}" alt="#{user.login}"
    .user__full_name
      i class="#{user.decorate.kind_icon}"
      = "#{user.decorate.full_name}"
    .user__login
      span.middle-dot-divider
        a href="#{user.decorate.provider_url}"
          i class="#{user.decorate.provider_icon}"
          = user.login
      - if (created_at = user.created_at)
        span.middle-dot-divider
          | Member since #{created_at.to_s("%b %Y")}
    .user__repositories_count
      = "#{user.repositories.count} repositories"
    .user__description
      - if (location = user.location) && !location.blank?
        span.middle-dot-divider
          i class="fas fa-map-marker-alt"
          = location
      - if (company = user.company) && !company.blank?
        span.middle-dot-divider
          i class="fas fa-building"
          = company
    - if (bio = user.bio) && !bio.blank?
      .user__bio.text_muted
        = bio
    - if (email = user.email) && !email.blank?
      .user__email
        i class="fas fa-envelope"
        a href="mailto:#{email}" = email
    - if (website = user.website) && !website.blank?
      .user__website
        i class="fas fa-link"
        a href="#{website}" = website
