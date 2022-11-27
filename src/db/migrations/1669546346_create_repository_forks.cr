class CreateRepositoryForks
  include Clear::Migration

  def change(dir)
    dir.up do
      create_table(:repository_forks) do |t|
        t.references to: "repositories", name: "parent_id", on_delete: "cascade", null: false, primary: true
        t.references to: "repositories", name: "fork_id", on_delete: "cascade", null: false, primary: true

        t.index ["parent_id", "fork_id"], using: :btree, unique: true
      end
    end

    dir.down do
      create_table(:repository_forks) { }
    end
  end
end
