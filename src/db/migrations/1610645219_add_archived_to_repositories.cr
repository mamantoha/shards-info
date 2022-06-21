class AddArchivedToRepositories
  include Clear::Migration

  def change(dir)
    dir.up do
      add_column "repositories", "archived", :bool, nullable: false, default: "false"
    end

    dir.down do
      add_column "repositories", "archived", :bool
    end
  end
end
