class UpdateLanguagesColorJob < PeriodicJobWithErrorHandler
  run_every 1.day

  def perform
    Helpers.update_languages_color
  end
end
