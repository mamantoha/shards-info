class CreateReleases
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table(:releases) do |t|
        t.column :tag_name, :string, null: false
        t.column :provider, :string, null: false
        t.column :provider_id, :integer
        t.column :name, :string
        t.column :body, :string
        t.column :created_at, :timestamp, null: false
        t.column :published_at, :timestamp

        t.references to: "repositories", name: "repository_id", on_delete: "cascade", null: false, primary: true

        t.index ["repository_id", "tag_name"], using: :btree, unique: true
      end
    end

    direction.down do
      create_table(:releases) { }
    end
  end
end
