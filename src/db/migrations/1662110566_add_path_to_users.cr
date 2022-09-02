class AddPathToUsers
  include Clear::Migration

  def change(dir)
    dir.up do
      add_column "users", "path", :string, nullable: true
    end

    dir.down do
      add_column "users", "path", :string
    end
  end
end
