class AddRelationships
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table(:relationships) do |t|
        t.references to: "repositories", name: "master_id", on_delete: "cascade", null: false, primary: true
        t.references to: "repositories", name: "dependency_id", on_delete: "cascade", null: false, primary: true

        t.column :development, :bool
        t.column :branch, :string
        t.column :version, :string

        t.index ["master_id", "dependency_id", "development"], using: :btree, unique: true
      end
    end

    direction.down do
      execute("DROP TABLE relationships")
    end
  end
end
