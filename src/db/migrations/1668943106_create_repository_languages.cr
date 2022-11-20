class CreateRepositoryLanguages
  include Clear::Migration

  def change(dir)
    dir.up do
      create_table(:languages) do |t|
        t.column :name, :string, index: true, unique: true, null: false
      end

      create_table(:repository_languages) do |t|
        t.references to: "languages", on_delete: "cascade", null: false, primary: true
        t.references to: "repositories", on_delete: "cascade", null: false, primary: true

        t.column :score, "decimal(5,2)"

        t.index ["language_id", "repository_id"], using: :btree, unique: true
      end
    end

    dir.down do
      create_table(:languages) { }
      create_table(:repository_languages) { }
    end
  end
end
