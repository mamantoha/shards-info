class AddSearch
  include Clear::Migration

  def change(dir)
    dir.up do
      # Creates function triggers
      #
      execute <<-SQL
        CREATE OR REPLACE FUNCTION tsv_trigger_insert_repositories() RETURNS trigger AS $$
        begin
          new.tsv :=
            setweight(to_tsvector('pg_catalog.simple', coalesce(new.name, '')), 'A') ||
            setweight(to_tsvector('pg_catalog.simple', coalesce(new.description, '')), 'B');
          return new;
        end
        $$ LANGUAGE plpgsql;
      SQL

      execute <<-SQL
        CREATE OR REPLACE FUNCTION tsv_trigger_update_repositories() RETURNS trigger AS $$
        begin
          SELECT setweight(to_tsvector('pg_catalog.simple', coalesce(r.name, '')), 'A') ||
                 setweight(to_tsvector('pg_catalog.simple', coalesce(r.description, '')), 'B') ||
                 setweight(to_tsvector('pg_catalog.simple', coalesce((string_agg(tags.name, ' ')), '')), 'C')
            INTO new.tsv
            FROM repositories r
            LEFT JOIN repository_tags ON repository_tags.repository_id = r.id
            LEFT JOIN tags ON tags.id = repository_tags.tag_id
            WHERE r.id = new.id
            GROUP BY r.id;
          return new;
        end
        $$ LANGUAGE plpgsql;
      SQL

      # Creates triggers
      #
      execute <<-SQL
        CREATE TRIGGER tsv_insert_repositories BEFORE INSERT
          ON repositories
          FOR EACH ROW
          EXECUTE PROCEDURE tsv_trigger_insert_repositories();
      SQL

      execute <<-SQL
        CREATE TRIGGER tsv_update_repositories BEFORE UPDATE
          ON repositories
          FOR EACH ROW
          EXECUTE PROCEDURE tsv_trigger_update_repositories();
      SQL
    end

    dir.down do
      execute("DROP FUNCTION tsv_trigger_insert_posts()")
      execute("DROP FUNCTION tsv_trigger_update_posts()")
      execute("DROP TRIGGER tsv_update_posts}")
      execute("DROP TRIGGER tsv_insert_posts}")
    end
  end
end
