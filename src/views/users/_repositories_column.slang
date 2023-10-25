- additional_info = false

== render "src/views/partials/sort_repositories_dropdown.slang"

- repositories.each(fetch_columns: true) do |repository|
  == render "src/views/repositories/_repository.slang"
