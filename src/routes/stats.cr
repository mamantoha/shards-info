router = Kemal::Router.new

router.namespace "/stats" do
  expires_in = 2.hours

  before do |env|
    if env.request.headers["X-Requested-With"]? != "XMLHttpRequest"
      halt env.status(403).text("Forbidden: Access via XHR only.")
    end

    env.response.content_type = "application/json"
  end

  get "/created_at" do
    CACHE.fetch("stats:created_at", expires_in: expires_in) do
      repositiries =
        Repository
          .query
          .select(
            "date_trunc('month', created_at)::date as year_month",
            "count(*) as count"
          )
          .group_by("year_month")
          .order_by("year_month", :asc)

      hsh = {} of String => Int64

      repositiries.each(fetch_columns: true) do |repository|
        hsh[repository["year_month"].as(Time).to_s("%Y-%m")] = repository["count"].as(Int64)
      end

      hsh.to_json
    end
  end

  get "/last_activity_at" do
    CACHE.fetch("stats:last_activity_at_json", expires_in: expires_in) do
      repositiries =
        Repository
          .query
          .select(
            "date_trunc('month', last_activity_at)::date as year_month",
            "count(*) as count"
          )
          .group_by("year_month")
          .order_by("year_month", :asc)

      hsh = {} of String => Int64

      repositiries.each(fetch_columns: true) do |repository|
        hsh[repository["year_month"].as(Time).to_s("%Y-%m")] = repository["count"].as(Int64)
      end

      hsh.to_json
    end
  end

  get "/repositories_growth" do
    # Calculates the cumulative count of repositories created before and on each year-month date,
    # including months with no repositories
    CACHE.fetch("stats:repositories_growth", expires_in: expires_in) do
      hsh = {} of String => Int64

      # https://github.com/crystal-lang/crystal was created on November 27, 2012
      date_start = "2012-11-01"

      month_series = Lustra::SQL.select(<<-SQL
        generate_series(
          '#{date_start}'::date,
          (SELECT date_trunc('month', MAX(created_at)) FROM repositories),
          '1 month'::interval
        )::date AS year_month
        SQL
      )

      Lustra::SQL
        .select({
          cumulative_count: "(SELECT COUNT(*) FROM repositories WHERE date_trunc('month', created_at)::date <= ms.year_month)",
          year_month:       "ms.year_month",
        })
        .with_cte({month_series: month_series})
        .from("month_series ms")
        .order_by("ms.year_month")
        .fetch do |attributes|
          hsh[attributes["year_month"].as(Time).to_s("%Y-%m")] = attributes["cumulative_count"].as(Int64)
        end

      hsh.to_json
    end
  end

  # Number of direct dependencies
  get "/direct_dependencies" do
    CACHE.fetch("stats:direct_dependencies", expires_in: expires_in) do
      hsh = {} of Int64 => Int64

      Lustra::SQL
        .select(
          "dependency_count",
          "COUNT(*) AS repository_count"
        )
        .from(<<-SQL
          (
            SELECT
              r.id,
              COUNT(rel.id) AS dependency_count
            FROM
              repositories r
            LEFT JOIN
              relationships rel ON r.id = rel.master_id
            GROUP BY
              r.id
          ) AS repo_dependency_count
          SQL
        )
        .group_by("dependency_count")
        .order_by("dependency_count", :asc)
        .fetch do |attributes|
          hsh[attributes["dependency_count"].as(Int64)] = attributes["repository_count"].as(Int64)
        end

      hsh.to_json
    end
  end

  # Number of transitive reverse dependencies
  get "/reverse_dependencies" do
    CACHE.fetch("stats:reverse_dependencies", expires_in: expires_in) do
      hsh = {} of String => Int64

      select_dependency_range = <<-SQL
        CASE
          WHEN dependency_count BETWEEN 1 AND 29 THEN dependency_count::text
          WHEN dependency_count BETWEEN 30 AND 100 THEN CONCAT((dependency_count / 10) * 10, '-', (dependency_count / 10) * 10 + 9)
          ELSE CONCAT((dependency_count / 100) * 100, '-', (dependency_count / 100) * 100 + 99)
        END AS dependency_range
        SQL

      Lustra::SQL
        .select(
          select_dependency_range,
          "COUNT(*) AS repository_count"
        )
        .from(<<-SQL
          (
            SELECT
              r.id,
              COUNT(rel.id) AS dependency_count
            FROM
              repositories r
            LEFT JOIN
              relationships rel ON r.id = rel.dependency_id
            GROUP BY
              r.id
          ) AS repo_dependency_count
          SQL
        )
        .group_by("dependency_range")
        .order_by("MIN(dependency_count)")
        .where("dependency_count > 0")
        .fetch do |attributes|
          hsh[attributes["dependency_range"].as(String)] = attributes["repository_count"].as(Int64)
        end

      hsh.to_json
    end
  end

  get "/user_repositories_count" do
    CACHE.fetch("stats:user_repositories_count", expires_in: expires_in) do
      hsh = {} of Int64 => Int64

      Lustra::SQL
        .select(
          "repo_count",
          "COUNT(*) AS user_count"
        )
        .from(<<-SQL
          (
            SELECT
              user_id,
              COUNT(*) AS repo_count
            FROM
              repositories
            GROUP BY
              user_id
          ) AS user_repos
          SQL
        )
        .group_by("repo_count")
        .order_by("repo_count")
        .fetch do |attributes|
          hsh[attributes["repo_count"].as(Int64)] = attributes["user_count"].as(Int64)
        end

      hsh.to_json
    end
  end

  get "/repositories_provider_count" do
    CACHE.fetch("stats:repositories_provider_count", expires_in: expires_in) do
      hsh = {} of String => Int64

      Repository
        .query
        .select("provider, COUNT(*) AS count")
        .group_by("provider")
        .order_by(count: :desc)
        .each(fetch_columns: true) do |repository|
          hsh[repository.provider] = repository.attributes["count"].as(Int64)
        end

      hsh.to_json
    end
  end

  get "/users_provider_count" do
    CACHE.fetch("stats:users_provider_count", expires_in: expires_in) do
      hsh = {} of String => Int64

      User
        .query
        .select("provider, COUNT(*) AS count")
        .group_by("provider")
        .order_by(count: :desc)
        .each(fetch_columns: true) do |user|
          hsh[user.provider] = user.attributes["count"].as(Int64)
        end

      hsh.to_json
    end
  end
end

mount router
