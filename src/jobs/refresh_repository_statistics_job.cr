class RefreshRepositoryStatisticsJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    Lustra::SQL.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY public.repository_statistics")
  end
end
