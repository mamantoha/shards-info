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
