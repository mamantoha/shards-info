require "../lib/gitlab"

class SyncRecentGitlabJob < Mosquito::PeriodicJob
  run_every 30.minutes

  def perform
    projects = gitlab_client.recently_updated

    projects.each do |_gitlab_project|
      if repository = Repository.query.find({provider: "gitlab", provider_id: _gitlab_project.id})
        # Update if repository has been changed
        if repository.last_activity_at != _gitlab_project.last_activity_at
          sync_project(_gitlab_project)
        end
      else
        # Create new repository
        sync_project(_gitlab_project)
      end
    end
  end

  private def gitlab_client
    @gilab_client ||= Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])
  end

  private def sync_project(_gitlab_project : Gitlab::Project)
    gitlab_project = gitlab_client.project(_gitlab_project.id)

    GitlabHelpers.sync_project(gitlab_project)
  end
end
