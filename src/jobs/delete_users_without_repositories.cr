class DeleteUsersWithoutRepositories < PeriodicJobWithErrorHandler
  run_every 1.day

  def perform
    users = User.query.missing(:repositories)

    users.each(&.delete)
  end
end
