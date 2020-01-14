require "../../config/config"
require "../gitlab"

gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

projects = gitlab_client.projects
projects.each do |project|
  # TODO
end
