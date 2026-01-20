class SyncRecentCodebergJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    codeberg_client = Forgejo::API.new("https://codeberg.org/api/v1", ENV["CODEBERG_TOKEN"])
    codeberg_repos = codeberg_client.repos_search("Crystal", topic: true).data

    codeberg_repos.each do |codeberg_repo|
      next if codeberg_repo.private?

      CodebergHelpers.sync_repo(codeberg_repo)
    end
  end
end
