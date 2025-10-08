class DeleteOrphanTags < PeriodicJobWithErrorHandler
  run_every 1.day

  def perform
    tags =
      Tag
        .query
        .left_join(:repository_tags)
        .where { repository_tags.id == nil }

    tags.each(&.delete)
  end
end
