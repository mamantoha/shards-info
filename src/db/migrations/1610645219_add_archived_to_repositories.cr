class AddArchivedToRepositories
  include Clear::Migration
  def change(direction)
    direction.up do
      add_column "repositories", "archived", :bool, nullable: false, default: "false"
    end

    direction.down do
      add_column "repositories", "archived", :bool
    end
  end
end
