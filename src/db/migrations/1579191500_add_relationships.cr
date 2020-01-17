class AddRelationships
  include Clear::Migration

  def change(direction)
    direction.up do
      add_column "repositories", "shard_yml", "text"

      create_table(:relationships, id: false) do |t|
        t.references to: "repositories", name: "master_id", on_delete: "cascade", null: false, primary: true
        t.references to: "repositories", name: "dependency_id", on_delete: "cascade", null: false, primary: true

        t.column :development, :bool
        t.column :branch, :string
        t.column :version, :string

        t.index ["master_id", "dependency_id", "development"], using: :btree, unique: true
      end
    end

    direction.down do
      drop_column "repositories", "shard_yml", "text"

      execute("DROP TABLE relationships")
    end
  end
end
