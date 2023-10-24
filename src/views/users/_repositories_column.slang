- additional_info = false

.row.justify-content-end
  .col-auto.vertical-center
    label
      | Sort by
  .col-auto
    .dropdown
      button.btn.btn-secondary.btn-sm.dropdown-toggle type="button" data-bs-toggle="dropdown" aria-expanded="false"
        = Helpers::REPOSITORIES_SORT_OPTIONS[sort]
      ul.dropdown-menu
        li
          - Helpers::REPOSITORIES_SORT_OPTIONS.each do |key, value|
            a.dropdown-item href="/#{user.provider}/#{user.login}?sort=#{key}" class="#{key == sort ? "disabled" : ""}"
              = value

- repositories.each(fetch_columns: true) do |repository|
  == render "src/views/repositories/_repository.slang"
