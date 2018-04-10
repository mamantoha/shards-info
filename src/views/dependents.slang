div
  h1.page__heading
    ' Dependent
    i.page__subheading
      ' on
      a href="#{repo.html_url}" #{repo.full_name}

== render "src/views/dependents/paginataion.slang"

- dependent_repos.items.each do |item|
  - item_repo = item.repository
  == render "src/views/dependents/repo.slang"

== render "src/views/dependents/paginataion.slang"
