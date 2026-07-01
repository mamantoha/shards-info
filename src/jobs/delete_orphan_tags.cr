class DeleteOrphanTags < PeriodicJobWithErrorHandler
  run_every 1.day

  def perform
    tags = Tag.query.where.missing(:repository_tags)

    tags.each(&.delete)
  end
end
