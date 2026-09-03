class CreateVisitorsAndEvents
  include Lustra::Migration

  def change(dir)
    create_table(:visitors, id: false) do |t|
      t.column :id, :uuid, null: false, primary: true, default: "uuidv7()"
      t.column :remote_address, :string, null: false
      t.column :user_agent, :string
      t.column :location, :jsonb, null: false, default: "'{}'::jsonb"
      t.column :events_count, :int64, null: false, default: "0"

      t.timestamps
    end

    create_table(:events) do |t|
      t.references to: "visitors", name: "visitor_id", type: "uuid", on_delete: "cascade", null: false
      t.column :path, :string, null: false, index: true
      t.column :method, :string, null: false
      t.column :params, :jsonb, null: false, default: "'{}'::jsonb"

      t.timestamps
    end
  end
end
