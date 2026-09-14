class CreateRepositoryStatistics
  include Lustra::Migration

  def change(dir)
    dir.up do
      execute <<-SQL
        CREATE MATERIALIZED VIEW public.repository_statistics AS
        SELECT repositories.id AS repository_id,
               COALESCE(dependents.count, 0) AS dependents_count,
               COALESCE(dependencies.count, 0) AS dependencies_count,
               COALESCE(forks.count, 0) AS repository_forks_count
        FROM repositories
        LEFT JOIN (
          SELECT dependency_id, COUNT(*) AS count
          FROM relationships
          GROUP BY dependency_id
        ) dependents ON dependents.dependency_id = repositories.id
        LEFT JOIN (
          SELECT master_id, COUNT(*) AS count
          FROM relationships
          GROUP BY master_id
        ) dependencies ON dependencies.master_id = repositories.id
        LEFT JOIN (
          SELECT parent_id, COUNT(*) AS count
          FROM repository_forks
          GROUP BY parent_id
        ) forks ON forks.parent_id = repositories.id
        SQL

      execute <<-SQL
        CREATE UNIQUE INDEX repository_statistics_repository_id
        ON public.repository_statistics (repository_id)
        SQL
    end

    dir.down do
      execute "DROP MATERIALIZED VIEW public.repository_statistics"
    end
  end
end
