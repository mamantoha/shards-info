div
  h1.page__heading
    ' Dependent
    i.page__subheading
      ' on
      a href="/repos/#{repo.full_name}" #{repo.full_name}

== render "src/views/dependents/pagination.slang"

- dependent_repos.items.each do |item|
  - item_repo = item.repository
  == render "src/views/dependents/repo.slang"

== render "src/views/dependents/pagination.slang"
