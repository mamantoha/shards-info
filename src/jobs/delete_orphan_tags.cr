class DeleteOrphanTags < PeriodicJobWithErrorHandler
  run_every 1.day

  def perform
    tags =
      Tag
        .query
        .left_join("repository_tags") { var("repository_tags", "tag_id") == var("tags", "id") }
        .where { repository_tags.id == nil }

    tags.each(&.delete)
  end
end
