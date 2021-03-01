class AddIgnoreToRepositories
  include Clear::Migration

  def change(direction)
    direction.up do
      add_column "repositories", "ignore", :bool, nullable: false, default: "false"
    end

    direction.down do
      add_column "repositories", "ignore", :bool
    end
  end
end
