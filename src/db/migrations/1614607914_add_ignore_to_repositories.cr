class AddIgnoreToRepositories
  include Clear::Migration

  def change(dir)
    dir.up do
      add_column "repositories", "ignore", :bool, nullable: false, default: "false"
    end

    dir.down do
      add_column "repositories", "ignore", :bool
    end
  end
end
