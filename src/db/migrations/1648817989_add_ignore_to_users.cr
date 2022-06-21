class AddIgnoreToUsers
  include Clear::Migration

  def change(dir)
    dir.up do
      add_column "users", "ignore", :bool, nullable: false, default: "false"
    end

    dir.down do
      add_column "users", "ignore", :bool
    end
  end
end
