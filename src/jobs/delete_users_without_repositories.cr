class DeleteUsersWithoutRepositories < PeriodicJobWithErrorHandler
  run_every 1.day

  def perform
    users =
      User
        .query
        .left_join(:repositories)
        .where { repositories.id == nil }

    users.each(&.delete)
  end
end
