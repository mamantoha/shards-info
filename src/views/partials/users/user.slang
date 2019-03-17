.p-2
  .card style="width: 18rem;"
    img.card-img-top src="#{user.avatar_url}" alt="#{user.login}"
    .card-body
      h5.card-title
        a href="#{user.html_url}"
          i class="fab fa-github"
        a href="/repos/#{user.login}"
          == "#{user.login}"
