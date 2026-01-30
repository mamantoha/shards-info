class SyncRecentGitlabJob < PeriodicJobWithErrorHandler
  run_every 30.minutes

  def perform
    projects = gitlab_client.recently_updated

    projects.each do |gitlab_project|
      sync_project(gitlab_project)
    end
  end

  private def gitlab_client
    @gilab_client ||= GitlabHelpers.gitlab_client
  end

  private def sync_project(_gitlab_project : Gitlab::Project)
    gitlab_project = gitlab_client.project(_gitlab_project.id)

    GitlabHelpers.sync_project(gitlab_project)
  end
end
