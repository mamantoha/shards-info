require "../lib/gitlab"

class SyncRecentGitlabJob < Mosquito::PeriodicJob
  run_every 30.minutes

  def perform
    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    projects = gitlab_client.recently_updated

    projects.each do |_gitlab_project|
      gitlab_project = gitlab_client.project(_gitlab_project.id)

      if repository = Repository.query.find({provider: "gitlab", provider_id: gitlab_project.id})
        # Update if repository has been changed
        if repository.last_activity_at != gitlab_project.last_activity_at
          GitlabHelpers.sync_project(gitlab_project)
        end
      else
        # Create new repository
        GitlabHelpers.sync_project(gitlab_project)
      end
    end
  end
end
