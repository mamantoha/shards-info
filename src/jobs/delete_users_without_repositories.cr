require "../lib/github"

class DeleteUsersWithoutRepositories < Mosquito::PeriodicJob
  run_every 1.day

  def perform
    users =
      User
        .query
        .left_join("repositories") { var("repositories", "user_id") == var("users", "id") }
        .where { repositories.id == nil }

    users.each(&.delete)
  end
end
