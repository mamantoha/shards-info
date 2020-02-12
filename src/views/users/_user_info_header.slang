.page__heading.user_heading
  .container.text-center
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
      - if created_at = user.created_at
        span.middle-dot-divider
          | Member since #{created_at.to_s("%b %Y")}
    .user__repositories_count
      = "#{user.repositories.count} repositories"
    .user__description
      - if (location = user.location) && (!user.location.to_s.empty?)
        span.middle-dot-divider
          i class="fas fa-map-marker-alt"
          = location
      - if (company = user.company) && (!user.company.to_s.empty?)
        span.middle-dot-divider
          i class="fas fa-building"
          = company
    - if (bio = user.bio) && (!user.bio.to_s.empty?)
      .user__bio.text_muted
        = bio
    - if (email = user.email) && (!user.email.to_s.empty?)
      .user__email
        i class="fas fa-envelope"
        a href="mailto:#{email}" = email
    - if (website = user.website) && (!user.website.to_s.empty?)
      .user__website
        i class="fas fa-link"
        a href="#{website}" = website
