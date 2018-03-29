.user__avatar
  img src="#{user.avatar_url}"
.user__name
  .name
    = user.name
  .login
    a href="#{user.html_url}" target="_blank"
      i class="fab fa-github"
    = user.login
  .user__info
    .user__info_item
      ' Followers
      span class="badge badge-secondary"= user.followers
    .user__info_item
      ' Following
      span class="badge badge-secondary"= user.following
hr
- if user.company
  .user__company
    i class="fas fa-users"
    = user.company
- if user.location
  .user__location
    i class="fas fa-globe"
    = user.location
- if user.email
  .user__email
    i class="fas fa-at"
    a href="mailto:#{user.email}" = user.email
- if user.blog
  .user__blog
    i class="fas fa-rss"
    a href="#{user.blog}" target="_blank" = user.blog
