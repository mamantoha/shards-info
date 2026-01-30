class SyncRecentCodebergJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    codeberg_client = CodebergHelpers.codeberg_client
    codeberg_repos = codeberg_client.repos_search("Crystal", topic: true).data

    codeberg_repos.each do |codeberg_repo|
      next if codeberg_repo.private?

      CodebergHelpers.sync_repo(codeberg_repo)
    end
  end
end
