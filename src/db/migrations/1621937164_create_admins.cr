class CreateAdmins
  include Lustra::Migration

  def change(dir)
    dir.up do
      create_table(:admins) do |t|
        t.column :provider, :string, null: false
        t.column :uid, :string, null: false
        t.column :raw_json, :text, null: false
        t.column :role, :integer, default: 0
        t.column :name, :string
        t.column :email, :string
        t.column :nickname, :string
        t.column :first_name, :string
        t.column :last_name, :string
        t.column :location, :string
        t.column :image, :string
        t.column :phone, :string
        t.timestamps

        t.index [:provider, :uid], using: :btree, unique: true
      end
    end

    dir.down do
      create_table(:admins) { }
    end
  end
end
