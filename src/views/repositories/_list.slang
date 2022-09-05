- additional_info = true

- repositories.each(fetch_columns: true) do |repository|
  == render "src/views/repositories/_repository.slang"
