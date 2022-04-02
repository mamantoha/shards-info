class AddIgnoreToUsers
  include Clear::Migration

  def change(direction)
    direction.up do
      add_column "users", "ignore", :bool, nullable: false, default: "false"
    end

    direction.down do
      add_column "users", "ignore", :bool
    end
  end
end
