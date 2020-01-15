require "../../config/config"
require "../gitlab"

gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

print "Getting projects from Giltab..."
projects = gitlab_client.projects

puts "OK!"

projects.each do |project|
  owner = project.namespace
  tags = project.tag_list

  user = User.query.find_or_create({provider: "gitlab", login: owner.path}) do |u|
    u.provider_id = owner.id
    u.name = owner.name
    u.kind = owner.kind
    u.avatar_url = owner.avatar_url
    u.synced_at = Time.utc
  end

  repository = Repository.query.find_or_create({provider: "gitlab", provider_id: project.id}) do |r|
    r.user = user
    r.name = project.path
    r.description = project.description
    r.last_activity_at = project.last_activity_at
    r.stars_count = project.star_count
    r.forks_count = project.forks_count
    r.open_issues_count = project.open_issues_count
    r.synced_at = Time.utc
  end

  # tags.each do |name|
  #   tag = Tag.query.find_or_create({name: name}) { }
  #   repository.tags << tag
  # end

  repository.tags = tags
end
