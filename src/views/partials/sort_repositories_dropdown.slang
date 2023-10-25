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
            - sort_param = "#{route_path.ends_with?('?') ? "" : "&"}sort=#{key}"
            a.dropdown-item href="#{route_path}#{sort_param}" class="#{key == sort ? "disabled" : ""}"
              = value
