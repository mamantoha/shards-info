.p-2
  .card style="width: 18rem;"
    img.card-img-top src="#{user.avatar_url}" alt="#{user.login}"
    .card-body
      h5.card-title
        a href="/#{user.provider}/#{user.login}"
          i class="fab #{user.provider_icon}"
          == "#{user.login}"
    ul class="list-group list-group-flush"
      li class="list-group-item"
        | #{user.attributes["repositories_count"]} repositories
