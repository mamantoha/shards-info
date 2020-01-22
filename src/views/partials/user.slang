.user__avatar
  img src="#{user.avatar}" alt="#{user.login}"
.user__name
  - if user.name
    .name
      = user.name
  .login
    a href="#{user.provider_url}"
      i class="#{user.provider_icon}"
    = user.login
hr
  - if created_at = user.created_at
    .user__created_at
      i class="fas fa-users"
      | Member since #{created_at.to_s("%b %Y")}
