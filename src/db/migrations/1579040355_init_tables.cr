class InitTables
  include Clear::Migration

  def change(dir)
    dir.up do
      execute("CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;")

      create_table(:users) do |t|
        t.column :provider, :string, null: false
        t.column :provider_id, :integer, null: false
        t.column :login, :citext, null: false, index: true
        t.column :name, :string
        t.column :kind, :string, null: false
        t.column :avatar_url, :string
        t.column :created_at, :timestamp
        t.column :synced_at, :timestamp, null: false

        t.index [:provider, :provider_id], using: :btree, unique: true
        t.index [:provider, :login], using: :btree, unique: true
      end

      create_table(:repositories) do |t|
        t.column :provider, :string, null: false
        t.column :provider_id, :integer, null: false
        t.column :name, :citext, null: false, index: true
        t.column :description, :string
        t.column :shard_yml, :string
        t.column :readme, :string
        t.column :changelog, :string
        t.column :license, :string
        t.column :last_activity_at, :timestamp, null: false, index: true
        t.column :stars_count, :integer, default: 0
        t.column :forks_count, :integer, default: 0
        t.column :open_issues_count, :integer, default: 0
        t.column :synced_at, :timestamp, null: false
        t.column :created_at, :timestamp
        t.column :updated_on, :timestamp, default: "NOW()"
        t.column :tsv, "tsvector"

        t.references to: "users", name: "user_id", on_delete: "cascade", null: false, primary: true

        t.index [:provider, :provider_id], using: :btree, unique: true
        t.index :tsv, using: :gin
      end

      create_table(:tags) do |t|
        t.column :name, :string, index: true, unique: true, null: false
      end

      create_table(:repository_tags) do |t|
        t.references to: "tags", name: "tag_id", on_delete: "cascade", null: false, primary: true
        t.references to: "repositories", name: "repository_id", on_delete: "cascade", null: false, primary: true

        t.index ["tag_id", "repository_id"], using: :btree, unique: true
      end
    end

    dir.down do
      execute("DROP TABLE users")
      execute("DROP TABLE repositories")
      execute("DROP TABLE tags")
      execute("DROP TABLE repository_tags")
    end
  end
end
