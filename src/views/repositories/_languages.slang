- repository_languages = repository.repository_languages.with_language.order_by(score: :desc)

.repository__languages
  .progress style="height: 8px;"
    - repository_languages.each do |repository_language|
      - language = repository_language.language
      .progress-bar role="progressbar" style="width: #{repository_language.score}%; background-color: #{language.color} !important;" aria-valuemin="0" aria-valuemax="100"

  .d-flex.flex-wrap.small.mt-2
    - repository_languages.each do |repository_language|
      - language = repository_language.language
      a.me-3 href="/languages/#{URI.encode_path(language.name)}"
        svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16"
          path fill="#{language.color}" fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8z"
        span.fw-bold= language.name
        span= "#{repository_language.score}%"
